; docformat = 'rst'

;+
; Allows substitution into a text file specified template by data held in
; structures or objects.
;
; :Examples:
;   The typical template use from a template file looks something like::
;
;     template = obj_new('MGffTemplate', template_filename)
;     template->process, data, output_filename
;     obj_destroy, template
;
; :Todo:
;   Allow a C format code specification string as in::
;
;     [% "%0.1f" % temp %]
;
;   The format specification could be a variable itself, as in::
;
;     [% format % temp %]
;
;   where the template was processed with variables like::
;
;     { format: '%0.1f', temp: 77. }
;
; :Author:
;   Michael Galloy
;
;
; :Requires:
;   IDL 6.1
;
; :Uses:
;   `MGffTokenizer`
;
; :Categories:
;   input/output
;
; :Properties:
;   spaces
;     number of spaces to indent the include
;   string_array
;     set to indicate that `template_filename` is actually a string array
;     containing the template
;-

;= MGffForTemplate implementation

;+
; Implements the getVariable method. This routine returns a value of a
; variable given the variable's name as a string. The only variable this
; object should contain is the FOREACH loop index variable.
;
; :Private:
;
; :Returns:
;   any type
;
; :Params:
;   name : in, required,type=string
;     name of the variable
;
; :Keywords:
;   found : out, optional, type=boolean
;     true if the variable was found
;-
function mgfffortemplate::getVariable, name, found=found
  compile_opt strictarr

  found = 0B

  ; variable name must be a string
  if (size(name, /type) ne 7) then return, -1L

  ; compare names case insensitively
  if (strupcase(name) eq strupcase(self.name)) then begin
    found = 1B
    return, *self.value
  endif else return, -1L
end


;+
; Sets the FOREACH loop index variable.
;
; :Private:
;
; :Params:
;   value : in, required, type=any
;     new value of the FOREACH loop index variable
;-
pro mgfffortemplate::setVariable, value
  compile_opt strictarr

  *self.value = value
end


;+
; Free resources.
;
; :Private:
;-
pro mgfffortemplate::cleanup
  compile_opt strictarr

  ptr_free, self.value
end


;+
; Initialize the instance variables.
;
; :Private:
;
; :Returns:
;   1 for success, 0 for failure
;
; :Params:
;   name : in, required, type=string
;     name of the FOREACH loop index variable
;   value : in, required, type=any
;     initial value for the FOREACH loop index variable
;-
function mgfffortemplate::init, name, value
  compile_opt strictarr

  self.name = name
  self.value = ptr_new(value)

  return, 1L
end


;+
; Define instance variables. This class is used internally by the
; MGffTemplate class to handle the variable associated with a FOREACH loop.
;
; :Private:
;
; :Fields:
;   name
;     name of the FOREACH loop index variable.
;   value
;     pointer to the value of the FOREACH loop index variable.
;-
pro mgfffortemplate__define
  compile_opt strictarr

  define = { mgfffortemplate, $
             name: '', $
             value: ptr_new() $
           }
end


;= MGffCompoundTemplate implementation

;+
; Implements the getVariable method. This routine returns a value of a
; variable given the variable's name as a string. This routine checks its
; subobjects for the variable.
;
; :Private:
;
; :Returns:
;   any type
;
; :Params:
;   name : in, required, type=string
;     name of the variable
;
; :Keywords:
;   found : out, optional, type=boolean
;     true if the variable was found
;-
function mgffcompoundtemplate::getVariable, name, found=found
  compile_opt strictarr
  on_error, 2

  ; variable name must be a string
  if (size(name, /type) ne 7) then begin
    found = 0B
    return, -1L
  endif

  ; check first template for variable
  if (obj_valid(self.template1)) then begin
    val = self.template1->getVariable(name, found=found)
  endif else found = 0B

  ; check the second template if not found in first
  if (found) then begin
    return, val
  endif else begin
    if (size(*self.template2, /type) eq 11) then begin
      if (obj_valid(*self.template2)) then begin
        val = (*self.template2)->getVariable(name, found=found)
        return, found ? val : -1L
      endif else begin
        found = 0B
        return, -1L
      endelse
    endif else if (size(*self.template2, /type) eq 8) then begin
      ind = where(tag_names(*self.template2) eq strupcase(name), count)
      if (count eq 0) then begin
        found = 0B
        return, -1L
      endif else begin
        found = 1B
        return, (*self.template2).(ind[0])
      endelse
    endif
  endelse
end


;+
; Free resources.
;
; :Private:
;-
pro mgffcompoundtemplate::cleanup
  compile_opt strictarr

  ptr_free, self.template2
end


;+
; Initialize instance variables.
;
; :Private:
;
; :Returns:
;   1L
;
; :Params:
;   template1 : in, required, type=object
;     an object which implements the `getVariable` method
;   template2 : in, required, type=object
;     an object which implements the `getVariable` method or a structure
;-
function mgffcompoundtemplate::init, template1, template2
  compile_opt strictarr
  on_error, 2

  if (size(template1, /type) ne 11) then begin
    message, 'invalid type for template1: ' + size(template1, /tname)
  endif

  type = size(template2, /type)
  if (type ne 8 && type ne 11) then begin
    message, 'invalid type for template2: ' + size(template2, /tname)
  endif

  self.template1 = template1
  self.template2 = ptr_new(template2)

  return, 1
end


;+
; Define instance variables. This class is used internally by the
; MGffTemplate class to handle the variables associated with a SCOPE
; directive.
;
; :Private:
;
; :Fields:
;   template1
;     a subobject implementing the `getVariable` method
;   template2
;     a subobject implementing the `getVariable` method
;-
pro mgffcompoundtemplate__define
  compile_opt strictarr

  define = { mgffcompoundtemplate, $
             template1: obj_new(), $
             template2: ptr_new() $
           }
end


;= MGffTemplate implementation

;+
; Make a string array which has an empty first element and all the rest are
; given by `spaces`.
;
; :Private:
;
; :Returns:
;   `strarr`
;
; :Params:
;   spaces : in, required, type=string
;     string to prefix all elements of the returned array by (except first)
;   n : in, required, type=integer
;     number of elements in returned array
;-
function mgfftemplate_makespace, spaces, n
  compile_opt strictarr

  result = strarr(n)
  if (n gt 1L) then result[1:*] = spaces
  return, result
end


;+
; Wrapper for PRINTF that recognizes LUN=-3 as /dev/null.
;
; :Private:
;
; :Params:
;   lun : in, required, type=LUN
;     logical unit number to direct output to, -3 means /dev/null
;   data : in, required, type=any
;     data to print
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     keywords to `PRINTF`
;-
pro mgfftemplate::_printf, lun, data, _extra=e
  compile_opt strictarr
  on_error, 2

  if (lun eq -3) then return else begin
    if (n_elements(data) gt 1) then begin
      if (size(data, /type) eq 10) then begin
        for i = 0L, n_elements(data) - 1L do begin
          self->_printf, lun, (*data)[i], _extra=e
        endfor
      endif else begin
        printf, lun, transpose(data), _extra=e
      endelse
    endif else begin
      if (size(data, /type) eq 10) then begin
        self->_printf, lun, *data, _extra=e
      endif else begin
        printf, lun, data, _extra=e
      endelse
    endelse
  endelse
end


;+
; Process an [% IF %] directive. Note: this routine uses SCOPE_VARFETCH to pull
; variables from the template into the local scope of this routine. Therefore
; all the local variables have a prefix of "mgfftemplate$" to avoid name
; clashes.
;
; :Private:
;
; :Params:
;   mgfftemplate$variables : in, required, type=structure
;     anonymous structure of variables
;   mgfftemplate$output_lun : in, required, type=LUN
;     logical unit number of output file
;-
pro mgfftemplate::_process_if, mgfftemplate$variables, mgfftemplate$output_lun
  compile_opt strictarr, logical_predicate
  on_error, 2

  ; get full expression
  mgfftemplate$expression = ''
  mgfftemplate$post_delim = ''
  while (strpos(mgfftemplate$post_delim, '%]') eq -1) do begin
    mgfftemplate$expression += ' ' + self.tokenizer->next(post_delim=mgfftemplate$post_delim)
  endwhile

  ; get values of variables in the expression
  mgfftemplate$delimiters = '"'' +-*/=^<>|&?:.[]{}()#~,'
  mgfftemplate$vars = strsplit(mgfftemplate$expression, $
                               mgfftemplate$delimiters, $
                               /extract, $
                               count=mgfftemplate$nvars)
  for i = 0, mgfftemplate$nvars - 1L do begin
    mgfftemplate$result = self->_getVariable(mgfftemplate$variables, $
                                             mgfftemplate$vars[i], $
                                             found=mgfftemplate$varFound)
    if (mgfftemplate$varFound) then begin
      (scope_varfetch(mgfftemplate$vars[i], /enter)) = mgfftemplate$result
    endif
  endfor

  ; evaluate the expression
  mgfftemplate$result = execute('mgfftemplate$condition = ' + mgfftemplate$expression, 1, 1)
  if (mgfftemplate$result) then begin
    mgfftemplate$new_output_lun = mgfftemplate$condition ? mgfftemplate$output_lun : -3
  endif else mgfftemplate$new_output_lun = -3

  self->_process_tokens, mgfftemplate$variables, mgfftemplate$new_output_lun, $
                         else_clause=mgfftemplate$else_clause
  if (keyword_set(mgfftemplate$else_clause)) then begin
    if (mgfftemplate$result) then begin
      mgfftemplate$new_output_lun = ~mgfftemplate$condition ? mgfftemplate$output_lun : -3
    endif else mgfftemplate$new_output_lun = mgfftemplate$output_lun
    self->_process_tokens, mgfftemplate$variables, mgfftemplate$new_output_lun
  endif
end


;+
; Process a [% FOREACH %] directive.
;
; :Private:
;
; :Params:
;   variables : in, required, type=structure
;     anonymous structure of variables
;   output_lun : in, required, type=LUN
;     logical unit number of output file
;-
pro mgfftemplate::_process_foreach, variables, output_lun
  compile_opt strictarr
  on_error, 2

  loopVariable = self.tokenizer->next()
  in = self.tokenizer->next(post_delim=post_delim)

  loopVariable = strtrim(loopVariable, 2)

    self->_process_variable, '', variables, output_lun, $
                           value=array, post_delim=post_delim, $
                           found=found

  if (~keyword_set(found) && (output_lun ne -3L)) then begin
    message, 'FOR loop array expression not found'
  endif

  if (output_lun eq -3) then array = ''

  ofor = obj_new('MGffForTemplate', loopVariable, array[0])
  ocompound = obj_new('MGffCompoundTemplate', ofor, variables)
  pos = self.tokenizer->savePos()
  for i = 0L, n_elements(array) - 1L do begin
      ofor->setVariable, array[i]
      self.tokenizer->restorePos, pos
      self->_process_tokens, ocompound, output_lun
  endfor
  obj_destroy, [ofor, ocompound]
end


;+
; Wrapped line by line copy to avoid crashing if the include file is empty.
;
; :Private:
;
; :Params:
;   filename : in, required, type=string
;     filename to include
;   output_lun : in, required, type=long
;     LUN to output contents of file to
;
; :Keywords:
;   spaces : in, required, type=string
;     indentation of output
;-
pro mgfftemplate::_copyFile, filename, output_lun, spaces=spaces
  compile_opt strictarr

  error = 0L
  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    free_lun, insertLun
    return
  endif

  openr, insertLun, filename, /get_lun
  line = ''
  while (~eof(insertLun)) do begin
    readf, insertLun, line
    self->_printf, output_lun, spaces + line
  endwhile
  free_lun, insertLun
end


;+
; Process an [% INCLUDE filename %] directive. This includes the file
; specified by the "filename" variable directly (with not processing), as in
; the INSERT directive except the filename is specified with a variable.
;
; :Private:
;
; :Params:
;   variables : in, required, type=structure
;     anonymous structure of variables
;   output_lun : in, required, type=LUN
;     logical unit number of output file
;
; :Keywords:
;   spaces : in, optional, type=integer, default=0
;     number of spaces to indent the include
;-
pro mgfftemplate::_process_include, variables, output_lun, spaces=spaces
  compile_opt strictarr
  on_error, 2

  filenameVariable = self.tokenizer->next()
  if (output_lun eq -3) then return

  filename = self->_getVariable(variables, filenameVariable, found=found)

  line = self.tokenizer->getCurrentLine(number=lineNumber)

  if (~found) then begin
    message, 'variable ' + filenameVariable + ' not found on line ' $
               + strtrim(lineNumber, 2) + ' of ' + self.templateFilename $
               + ': ', $
             /informational, /noname, /continue
    message, line, /noname
  endif

  if (size(filename, /type) ne 7) then begin
    message, 'Variable ' + filenameVariable + ' must be a string on line ' $
               + strtrim(lineNumber, 2) + ' of ' + self.templateFilename $
               + ': ', $
             /informational, /noname, /continue
    message, line, /noname
  endif

  if (~file_test(filename)) then begin
    message, 'filename ' + filename + ' not found on line ' $
               + strtrim(lineNumber, 2) + ' of ' + self.templateFilename $
               + ': ', $
             /informational, /noname, /continue
    message, line, /noname
  endif

  self->_copyFile, filename, output_lun, spaces=spaces
end


;+
; Process a [% INCLUDE_TEMPLATE filename %] directive. This includes the
; file specified by the "filename" variable, processing it as a template with
; the same variables as the current template.
;
; :Private:
;
; :Params:
;   variables : in, required, type=structure
;     anonymous structure of variables
;   output_lun : in, required, type=LUN
;     logical unit number of output file
;
; :Keywords:
;   spaces : in, optional, type=integer, default=0
;     number of spaces to indent the include
;-
pro mgfftemplate::_process_include_template, variables, output_lun, spaces=spaces
  compile_opt strictarr
  on_error, 2

  filenameVariable = self.tokenizer->next()
  if (output_lun eq -3) then return

  filename = self->_getVariable(variables, filenameVariable, found=found)

  line = self.tokenizer->getCurrentLine(number=lineNumber)

  if (~found) then begin
    message, 'variable ' + filenameVariable + ' not found on line ' $
               + strtrim(lineNumber, 2) + ' of ' + self.templateFilename $
               + ': ', $
             /informational, /noname, /continue
    message, line, /noname
  endif

  if (size(filename, /type) ne 7) then begin
    message, 'Variable ' + filenameVariable + ' must be a string on line ' $
               + strtrim(lineNumber, 2) + ' of ' + self.templateFilename $
               + ': ', $
             /informational, /noname, /continue
    message, line, /noname
  endif

  if (~file_test(filename)) then begin
    message, 'filename ' + filename + ' not found on line ' $
               + strtrim(lineNumber, 2) + ' of ' + self.templateFilename $
               + ': ', $
             /informational, /noname, /continue
    message, line, /noname
  endif

  oinclude = obj_new('MGffTemplate', filename, spaces=spaces)
  oinclude->process, variables, lun=output_lun
  obj_destroy, oinclude
end


;+
; Process an [% INSERT filename %] directive. Insert the given filename. Here
; "filename" is not a variable; it is a directly specified filename. The
; filename can be absolute or relative to the template file.
;
; :Private:
;
; :Params:
;   output_lun : in, required, type=LUN
;     logical unit number of output file
;
; :Keywords:
;   spaces : in, optional, type=integer, default=0
;     number of spaces to indent the include
;-
pro mgfftemplate::_process_insert, output_lun, spaces=spaces
  compile_opt strictarr
  on_error, 2

  filename = self.tokenizer->next()

  ; fill out filenames that are relative to the template file
  cd, current=origDir
  cd, self.includeRoot
  filename = file_expand_path(filename)
  cd, origDir

  if (~file_test(filename)) then begin
    message, 'filename ' + filename + ' not found', /noname
  endif

  nlines = file_lines(filename)
  openr, insertLun, filename, /get_lun
  line = ''
  i = 0L
  while (~eof(insertLun)) do begin
    readf, insertLun, line
    self->_printf, output_lun, $
                   (i eq 0L ? '' : spaces) + line, $
                   format=(i eq nlines - 1L) ? '(A, $)' : '(A)'
    i++
  endwhile
  free_lun, insertLun
end


;+
; Process a [% SCOPE ovariables %] directive. Only valid for a object
; template.
;
; :Private:
;
; :Params:
;   variables : in, required, type=object
;     object with getVariable method
;   output_lun : in, required, type=LUN
;     logical unit number of output file
;-
pro mgfftemplate::_process_scope, variables, output_lun
    compile_opt strictarr
    on_error, 2

    ;if (size(variables, /type) ne 11) then begin
    ;  message, 'SCOPE directive only valid for object templates'
    ;endif

    varname = self.tokenizer->next()
    ovars = self->_getVariable(variables, varname, found=found)

    if (~found) then begin
        line = self.tokenizer->getCurrentLine(number=line_number)
        message, 'variable ' + varname + ' not found on line ' $
                   + strtrim(line_number, 2) + ' of ' + self.templateFilename $
                   + ': ', $
                 /informational, /noname, /continue
        message, line, /noname
    endif

    if (size(ovars, /type) ne 11) then begin
        self->_process_tokens, variables, output_lun
    endif else begin
        ocompound = obj_new('MGffCompoundTemplate', ovars, variables)
        self->_process_tokens, ocompound, output_lun
        obj_destroy, ocompound
    endelse
end


;+
; Finds a given variable name in a structure of variables or calls
; getVariable if variables is an object.
;
; :Private:
;
; :Returns:
;   value of variable or -1L if not found
;
; :Params:
;   variables : in, required, type=structure
;     structure of variables
;   name : in, required, type=string
;     name of a variable
;
; :Keywords:
;   found : out, optional, type=boolean
;     true if name is a variable in variables structure
;-
function mgfftemplate::_getVariable, variables, name, found=found
  compile_opt strictarr

  error = 0L
  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    found = 0B
    return, -1L
  endif

  case size(variables, /type) of
  8 : begin    ; structure
    ind = where(tag_names(variables) eq strupcase(name), count)
    found = count gt 0
    return, found ? variables.(ind[0]) : -1L
  end
  11 : begin    ; object
    result = variables->getVariable(name, found=found)
    return, result
  end
  else : begin
    found = 0B
    return, -1L
  end
  endcase
end


;+
; Process an [% expression %] directive. Note: this routine uses SCOPE_VARFETCH
; to pull variables from the template into the local scope of this routine.
; Therefore all the local variables have a prefix of "mgfftemplate$" to
; avoid name clashes.
;
; :Private:
;
; :Params:
;   mgfftemplate$expression : in, required, type=string
;     expression containing variable names to insert value of
;   mgfftemplate$variables : in, required, type=structure
;     anonymous structure of variables
;   mgfftemplate$output_lun : in, required, type=LUN
;     logical unit number of output file
;
; :Keywords:
;   post_delim : out, optional, type=string
;     delimiter after the returned token
;   value : out, optional, type=any
;     value of the expression evaluated
;   found : out, optional, type=boolean
;     true if the expression was evaluated without error
;   spaces : in, optional, type=integer, default=0
;     number of spaces to indent the include
;-
pro mgfftemplate::_process_variable, mgfftemplate$expression, $
                                     mgfftemplate$variables, $
                                     mgfftemplate$output_lun, $
                                     post_delim=mgfftemplate$post_delim, $
                                     value=mgfftemplate$value, $
                                     found=mgfftemplate$result, $
                                     spaces=mgfftemplate$spaces
  compile_opt strictarr, logical_predicate
  on_error, 2

  if (mgfftemplate$output_lun eq -3L) then return

  ; get full expression
  while (strpos(mgfftemplate$post_delim, '%]') eq -1) do begin
    mgfftemplate$expression += ' ' + self.tokenizer->next(post_delim=mgfftemplate$post_delim)
  endwhile

  ; get values of variables in the expression
  mgfftemplate$delimiters = '"'' +-*/=^<>|&?:.[]{}()#~,'
  mgfftemplate$vars = strsplit(mgfftemplate$expression, $
                               mgfftemplate$delimiters, $
                               /extract, $
                               count=mgfftemplate$nvars)
  for mgfftemplate$i = 0L, mgfftemplate$nvars - 1L do begin
    mgfftemplate$result = self->_getVariable(mgfftemplate$variables, $
                                             mgfftemplate$vars[mgfftemplate$i], $
                                             found=mgfftemplate$varFound)
    if (mgfftemplate$varFound) then begin
      (scope_varfetch(mgfftemplate$vars[mgfftemplate$i], /enter)) = mgfftemplate$result
    endif
  endfor

  ; evaluate expression
  mgfftemplate$result = execute('mgfftemplate$value = ' + mgfftemplate$expression, 1, 1)
  if (mgfftemplate$result) then begin
    if (size(mgfftemplate$value, /type) ne 7 $
          && size(mgfftemplate$value, /type) ne 8 $
          && size(mgfftemplate$value, /type) ne 11) then begin
      if (size(mgfftemplate$value, /type) eq 1) then begin
        mgfftemplate$value = fix(mgfftemplate$value)
      endif
      mgfftemplate$value = strtrim(mgfftemplate$value, 2)
    endif
    if (~arg_present(mgfftemplate$value)) then begin
      self->_printf, mgfftemplate$output_lun, $
                     mgfftemplate_makespace(mgfftemplate$spaces, $
                                            n_elements(mgfftemplate$value)) $
                       + mgfftemplate$value, $
                     format='(A, $)'
    endif
  endif else begin
    mgfftemplate$line = self.tokenizer->getCurrentLine(number=mgfftemplate$lineNumber)
    message, 'invalid expression "' + mgfftemplate$expression + '" on line ' $
               + strtrim(mgfftemplate$lineNumber, 2) + ' of ' + self.templateFilename $
               + ' (error = ' + !error_state.msg + ')'
  endelse
end


;+
; Process directives or plain text.
;
; :Private:
;
; :Params:
;   variables : in, required, type=structure
;     anonymous structure of variables
;   output_lun : in, required, type=LUN
;     logical unit number of output file
;
; :Keywords:
;   else_clause : out, optional, type=boolean
;     returns 1 if an `[% ELSE %]` directive was just processed
;-
pro mgfftemplate::_process_tokens, variables, output_lun, $
                                   else_clause=else_clause
  compile_opt strictarr
  on_error, 2

  while (~self.tokenizer->done()) do begin
    token = self.tokenizer->next(pre_delim=pre_delim, newline=newline, $
                                 post_delim=post_delim)
    if (newline) then begin
      self->_printf, output_lun, string(10B) + self.spaces, format='(A, $)'
    endif
    if (strpos(pre_delim, '[%') ne -1) then begin
      n_spaces = strpos(pre_delim, '[') - strpos(pre_delim, ']') - 1L
      spaces = n_spaces le 0 ? '' : string(bytarr(n_spaces) + 32B)
      self->_printf, output_lun, spaces, format='(A, $)'
      command = strtrim(token, 2)
      case strlowcase(command) of
        'foreach' : self->_process_foreach, variables, output_lun
        'if' : self->_process_if, variables, output_lun
        'include' : self->_process_include, variables, output_lun, spaces=spaces
        'include_template' : begin
          self->_process_include_template, variables, output_lun, spaces=spaces
        end
        'insert' : self->_process_insert, output_lun, spaces=spaces
        'scope' : self->_process_scope, variables, output_lun
        'end' : return
        'else' : begin
          else_clause = 1
          return
        end
        else : begin
          self->_process_variable, command, variables, output_lun, $
                                   post_delim=post_delim, spaces=spaces
        end
      endcase
    endif else if (strtrim(pre_delim, 2) eq '%]') then begin
      n_spaces = strlen(pre_delim) - strpos(pre_delim, ']') - 1L
      spaces = n_spaces le 0 ? '' : string(bytarr(n_spaces) + 32B)
      self->_printf, output_lun, spaces + token, format='(A, $)'
    endif else begin
      self->_printf, output_lun, pre_delim + token, format='(A, $)'
    endelse
  endwhile
end


;= MGffTemplate public interface

;+
; Process the template with the given variables and send output to the given
; filename.
;
; :Params:
;   variables : in, required, type=structure
;     either a structure or an object with getVariable method
;   output_filename : in, optional, type=string
;     filename of the output file
;
; :Keywords:
;   lun : in, optional, type=long
;     logical unit number of an already open file to send output to
;-
pro mgfftemplate::process, variables, output_filename, lun=output_lun
  compile_opt strictarr
  on_error, 2

  if (n_elements(output_lun) eq 0) then begin
    openw, output_lun, output_filename, /get_lun
    self->_process_tokens, variables, output_lun
    free_lun, output_lun
  endif else begin
    self->_process_tokens, variables, output_lun
  endelse
end


;+
; Reset the template to run again from the start of the template.
;-
pro mgfftemplate::reset
  compile_opt strictarr

  self.tokenizer->reset
end


;= MGffTemplate lifecycle methods

;+
; Frees resources.
;-
pro mgfftemplate::cleanup
  compile_opt strictarr

  obj_destroy, self.tokenizer
end


;+
; Create a template class for a given template. A template can be used many
; times with different sets of data sent to the process method.
;
; :Returns:
;   1 for success, 0 otherwise
;
; :Params:
;   template_filename : in, required, type=string
;     filename of the template file
;
; :Keywords:
;   spaces : in, optional, type=integer, default=0
;     number of spaces to indent the include
;   string_array : in, optional, type=boolean
;     set to indicate that `template_filename` is actually a string array
;     containing the template
;-
function mgfftemplate::init, template_filename, spaces=spaces, $
                             string_array=stringArray
  compile_opt strictarr
  on_error, 2

  if (n_params() ne 1) then message, 'template filename parameter required'

  self.templateFilename = keyword_set(stringArray) $
                            ? 'string input' $
                            : template_filename

  if (keyword_set(stringArray)) then begin
    cd, current=currentDir
    self.includeRoot = currentDir
  endif else begin
    self.includeRoot = file_dirname(template_filename)
  endelse

  self.spaces = n_elements(spaces) eq 0 ? '' : spaces

  self.tokenizer = obj_new('MGffTokenizer', template_filename, $
                           pattern='(\[\%)|(\%\])| ', string_array=stringArray)

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;   templateFilename
;     filename of the template file
;   tokenizer
;     `MGffTokenizer` used to break a template into tokens
;-
pro mgfftemplate__define
  compile_opt strictarr

  define = { MGffTemplate, $
             templateFilename: '', $
             includeRoot: '', $
             tokenizer: obj_new(), $
             spaces: '' $
           }
end

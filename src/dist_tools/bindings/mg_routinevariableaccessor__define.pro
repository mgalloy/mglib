; docformat = 'rst'

;+
; Class representing a wrapper for a routine to access a variable or pound
; define constant.
;
; :Private:
;
; :Properties:
;   name
;     name of routine to wrap
;   prefix
;     prefix to add to routine for name of wrapper routine
;   prototype
;     prototype line for the routine, if available
;   return_type
;     `SIZE` type code indicating return type of routine
;   n_min_parameters
;     minimum number of parameters for routine
;   n_max_parameters
;     maximum number of parameters for routine
;-


;+
; Set properties.
;-
pro mg_routineVariableAccessor::setProperty, name=name, $
                                             prefix=prefix, $
                                             cprefix=cprefix, $
                                             return_type=returnType, $
                                             prototype=prototype
  compile_opt strictarr

  if (n_elements(name) gt 0L) then self.name = name
  if (n_elements(prefix) gt 0L) then self.prefix = prefix
  if (n_elements(cprefix) gt 0L) then self.cprefix = cprefix
  if (n_elements(returnType) gt 0L) then begin
    *self.returnType = size(returnType, /type) eq 7L $
                         ? returnType $
                         : long(returnType)
  endif
  if (n_elements(prototype) gt 0L) then self.prototype = prototype
end


;+
; Get properties.
;-
pro mg_routineVariableAccessor::getProperty, name=name, $
                                             prefix=prefix, $
                                             cprefix=cprefix, $
                                             return_type=returnType, $
                                             is_function=is_function, $
                                             has_keywords=has_keywords, $
                                             n_min_parameters=nMinParameters, $
                                             n_max_parameters=nMaxParameters, $
                                             prototype=prototype
  compile_opt strictarr

  if (arg_present(name)) then name = self.name
  if (arg_present(prefix)) then prefix = self.prefix
  if (arg_present(cprefix)) then cprefix = self.cprefix
  if (arg_present(returnType)) then returnType = *self.returnType
  if (arg_present(is_function)) then is_function = 1B
  if (arg_present(has_keywords)) then has_keywords = 0L
  if (arg_present(nMinParameters)) then nMinParameters = 0L
  if (arg_present(nMaxParameters)) then nMaxParameters = 0L
  if (arg_present(prototype)) then prototype = self.prototype
end


;+
; Create string output for the routine's wrapper code.
;
; :Returns:
;    string
;
; :Keywords:
;    preamble
;      string/string array of code to be inserted after declarations, but before
;      argument checking
;-
function mg_routineVariableAccessor::output, preamble=preamble
  compile_opt strictarr

  output = ''

  if (self.prototype ne '') then begin
    output += string(self.prototype, mg_newline(), format='(%"// %s%s")')
  endif

  case size(*self.returnType, /type) of
    3: returnTypeStr = *self.returnType eq 0L ? 'void' : 'IDL_VPTR'
    7: returnTypeStr = 'IDL_VPTR'
  endcase
  output += string(returnTypeStr, $
                   self.cprefix, $
                   self.name, $
                   format='(%"static %s %s_%s(int argc, IDL_VPTR *argv, char *argk) {")')
  if (n_elements(preamble) gt 0L) then begin
    foreach p, preamble do begin
      output += string(mg_newline(), $
                       p, $
                       format='(%"%s  %s")')
    endforeach
  endif
  if (returnTypeStr ne 'void') then begin
    output += string(mg_newline(), $
                     mg_idltype(*self.returnType, /tmp_routine), $
                     self.name, $
                     format='(%"%s  return %s(%s);")')
  endif

  output += string(mg_newline(), format='(%"%s}")')

  return, output
end


;+
; Free resources.
;-
pro mg_routineVariableAccessor::cleanup
  compile_opt strictarr

  ptr_free, self.returnType
end


;+
; Create routine binding.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mg_routineVariableAccessor::init, _extra=e
  compile_opt strictarr

  self.prefix = 'GET_'
  self.cprefix = 'IDL'
  self.prototype = 'accessor'
  self.returnType = ptr_new(/allocate_heap)

  self->setProperty, _extra=e

  return, 1
end


;+
; Defines instance variables.
;
; :Fields:
;    name
;       name of the routine to call
;    prefix
;       prefix to add to routine for name of wrapper routine
;    returnType
;       type code for return value of the routine
;-
pro mg_routineVariableAccessor__define
  compile_opt strictarr

  define = { mg_routineVariableAccessor, $
             name: '', $
             prefix: '', $
             cprefix: '', $
             prototype: '', $
             returnType: ptr_new() $
           }
end

; docformat = 'rst'

;+
; Class representing a wrapper for a routine.
;
; :Private:
;
; :Properties:
;    name
;       name of routine to wrap
;    prefix
;       prefix to add to routine for name of wrapper routine
;    prototype
;       prototype line for the routine, if available
;    return_type
;       `SIZE` type code indicating return type of routine
;    n_min_parameters
;       minimum number of parameters for routine
;    n_max_parameters
;       maximum number of parameters for routine
;-


;+
; Set properties.
;-
pro mg_routinebinding::setProperty, name=name, $
                                    prefix=prefix, $
                                    cprefix=cprefix, $
                                    return_type=returnType, $
                                    return_pointer=returnPointer, $
                                    prototype=prototype
  compile_opt strictarr

  if (n_elements(name) gt 0L) then self.name = name
  if (n_elements(prefix) gt 0L) then self.prefix = prefix
  if (n_elements(cprefix) gt 0L) then self.cprefix = cprefix
  if (n_elements(returnType) gt 0L) then *self.returnType = returnType
  if (n_elements(returnPointer) gt 0L) then self.returnPointer = returnPointer
  if (n_elements(prototype) gt 0L) then self.prototype = prototype
end


;+
; Get properties.
;-
pro mg_routinebinding::getProperty, name=name, $
                                    prefix=prefix, $
                                    cprefix=cprefix, $
                                    return_type=returnType, $
                                    return_pointer=returnPointer, $
                                    n_min_parameters=nMinParameters, $
                                    n_max_parameters=nMaxParameters, $
                                    prototype=prototype
  compile_opt strictarr

  if (arg_present(name)) then name = self.name
  if (arg_present(prefix)) then prefix = self.prefix
  if (arg_present(cprefix)) then cprefix = self.cprefix
  if (arg_present(returnType)) then returnType = *self.returnType
  if (arg_present(returnPointer)) then returnPointer = self.returnPointer
  if (arg_present(nMinParameters)) then nMinParameters = n_elements(self.parameters)
  if (arg_present(nMaxParameters)) then nMaxParameters = n_elements(self.parameters)
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
function mg_routinebinding::output, preamble=preamble
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

  if (returnTypeStr ne 'void') then begin
    output += string(mg_newline(), $
                     mg_idltype(*self.returnType, /declaration), $
                     format='(%"%s  %s result;")')
  endif

  if (n_elements(preamble) gt 0L) then begin
    foreach p, preamble do begin
      output += string(mg_newline(), $
                       p, $
                       format='(%"%s  %s")')
    endforeach
  endif

  if (n_elements(self.parameters) gt 0L) then begin
    foreach p, self.parameters, i do begin
      output += string(mg_newline(), $
                       i, $
                       format='(%"%s  IDL_ENSURE_SIMPLE(argv[%d]);")')
      output += string(mg_newline(), $
                       (p.array && ~p.device) ? 'ARRAY' : 'SCALAR', $
                       i, $
                       format='(%"%s  IDL_ENSURE_%s(argv[%d])")')
      if (p.device || p.pointer) then begin
        output += string(mg_newline(), $
                         i, $
                         'IDL_TYP_PTRINT', $
                         (self.parameter_prototypes)[i], $
                         format='(%"%s  MG_ENSURE_TYPE(argv[%d], %s, \"%s\")")')
      endif else begin
        output += string(mg_newline(), $
                         i, $
                         mg_idltype(p.type, /type), $
                         (self.parameter_prototypes)[i], $
                         format='(%"%s  MG_ENSURE_TYPE(argv[%d], %s, \"%s\")")')
      endelse
    endforeach
  endif

  output += mg_newline() + '  '
  indent_len = 2L  ; start with two space indent from above line

  if (returnTypeStr ne 'void') then begin
    r = string(mg_idltype(*self.returnType, /declaration), $
               format='(%"result = (%s) ")')
    output += r
    indent_len += strlen(r)
  endif

  routine_call = string(self.name, format='(%"%s(")')
  output += routine_call
  indent_len += strlen(routine_call)
  indent = string(bytarr(indent_len) + 32B)

  if (n_elements(self.parameters) gt 0L) then begin
    foreach p, self.parameters, i do begin
      if (p.array) then begin
        if (p.device) then begin
          param = string(mg_idltype(p.type, /declaration), i, $
                         format='(%"(%s *) argv[%d]->value.ptrint")')
        endif else begin
          param = string(mg_idltype(p.type, /declaration), i, $
                         format='(%"(%s *) argv[%d]->value.arr->data")')
        endelse
      endif else begin
        if (p.type eq 7L) then begin
          param = string(i, mg_idltype(p.type), $
                         format='(%"IDL_STRING_STR(&argv[%d]->value.%s)")')
        endif else begin
          param = string((p.pointer && p.type ne 0L) ? '&' : '', $
                         i, $
                         mg_idltype(p.type, pointer=p.pointer && p.type eq 0L), $
                         format='(%"%sargv[%d]->value.%s")')
        endelse
      endelse
      output += string(i eq 0L ? '' : (mg_newline() + indent), $
                       param, $
                       i eq n_elements(self.parameters) - 1L ? '); ' : ', ', $
                       (self.parameter_prototypes)[i], $
                       format='(%"%s%s%s  // %s")')
    endforeach
  endif else output += ');'

  if (returnTypeStr ne 'void') then begin
    output += string(mg_newline(), $
                     mg_idltype(*self.returnType, /tmp_routine), $
                     format='(%"%s  return %s(result);")')
  endif

  output += string(mg_newline(), format='(%"%s}")')

  return, output
end


;+
; Add a positional parameter for the routine given a `SIZE` type code.
;
; :Keywords:
;    type : in, required, type=long
;       `SIZE` type code for the parameter
;    prototype : in, optional, type=string
;       C definition of the parameter
;    pointer : in, optional, type=boolean
;       set to indicate this parameter is a pointer
;    array : in, optional, type=boolean
;       set to indicate this parameter is a pointer to an array
;    device : in, optional, type=boolean
;       set to indicate this parameter is a device pointer
;
;-
pro mg_routinebinding::addParameter, type=type, $
                                     prototype=prototype, $
                                     pointer=pointer, $
                                     array=array, $
                                     device=device
  compile_opt strictarr

  self.parameters->add, { type: type, $
                          pointer: keyword_set(pointer), $
                          array: keyword_set(array), $
                          device: keyword_set(device) }
  self.parameter_prototypes->add, n_elements(prototype) eq 0L ? '' : prototype
end


;+
; Free resources.
;-
pro mg_routinebinding::cleanup
  compile_opt strictarr

  ptr_free, self.returnType
  obj_destroy, [self.parameters, self.parameter_prototypes]
end


;+
; Create routine binding.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mg_routinebinding::init, _extra=e
  compile_opt strictarr

  self.parameters = list()
  self.parameter_prototypes = list()

  self.prefix = ''
  self.cprefix = 'IDL'
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
;    parameters
;       `LIST` of parameter type codes
;-
pro mg_routinebinding__define
  compile_opt strictarr

  define = { mg_routinebinding, $
             name: '', $
             prototype: '', $
             prefix: '', $
             cprefix: '', $
             returnType: ptr_new(), $
             returnPointer: 0B, $
             parameters: obj_new(), $
             parameter_prototypes: obj_new() $
           }
end

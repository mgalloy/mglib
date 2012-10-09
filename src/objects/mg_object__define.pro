; docformat = 'rst'

;+
; Base class for objects to add a few introspection methods such as ::help
; and ::toString.
;-


;+
; Display internal help output with OBJECTS set for this object (so it shows
; instance data as well).
;-
pro mg_object::help
  compile_opt strictarr

  help, self, /objects
end


;+
; Returns a string representation of the object. By default, it returns the
; string that is displayed when an object is PRINTed.
;
; :Returns:
;    string
;-
function mg_object::toString
  compile_opt strictarr

  help, self, output=output
  tokens = strsplit(output, /extract)
  return, string(tokens[3])
end



function mg_object::_getClassInfo, classname, output=output, $
                                   function_start=functionStart
  compile_opt strictarr, hidden

  result = [classname, string(replicate(byte('='), strlen(classname)))]

  ; after this line, a declaration is a function; before it, it is a procedure
  functions_line = where(stregex(output, '^Compiled Functions:$', /boolean))

  matchesClassname = stregex(output, '^' + classname, /boolean)
  ind = where(matchesClassname, nMethods)

  for m = 0L, nMethods - 1L do begin
    line = output[ind[m]]
    tokens = strsplit(line, /extract, count=ntokens)

    args_decl = ''
    for a = 1L, ntokens - 1L do begin
      ; skip the "self" argument to methods
      if (a eq 1L && tokens[a] eq 'self') then continue

      ; parameters and keywords have different forms
      if (stregex(tokens[a], '[A-Z_$]+', /boolean)) then begin
        args_decl += string(args_decl eq '' ? '' : ', ', tokens[a], tokens[a], $
                            format='(%"%s%s=%s")')
      endif else begin
        args_decl += string(args_decl eq '' ? '' : ', ', tokens[a], $
                            format='(%"%s%s")')
      endelse
    endfor

    method_name = strlowcase(tokens[0])
    if (ind[m] gt functions_line[0]) then begin
      decl = string(method_name, args_decl, format='(%"function %s(%s)")')
    endif else begin
      decl = string(method_name, args_decl eq '' ? '' : ',', args_decl, $
                    format='(%"pro %s%s %s")')
    endelse

    result = [result, decl]
  endfor

  ;if (nMethods gt 0L) then result = [result, output[ind]]

  parents = obj_class(classname, /superclass)

  if (parents[0] ne '') then begin
    for p = 0L, n_elements(parents) - 1L do begin
      result = [result, '', self->_getClassInfo(parents[p], $
                                                output=output, $
                                                function_start=functionStart)]
    endfor
  endif

  return, result
end


function mg_object::_overloadHelp, varname
  compile_opt strictarr

  help, /routines, output=output

  ; find where functions start
  functionStart = (where(strmatch(output, 'Compiled Functions:')))[0]

  methodLines = self->_getClassInfo(obj_class(self), $
                                    output=output, $
                                    function_start=functionStart)

  return, methodLines
end


;+
; Define instance variables.
;-
pro mg_object__define
  compile_opt strictarr

  define = { mg_object, inherits IDL_Object }
end

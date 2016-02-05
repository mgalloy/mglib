; docformat = 'rst'

;+
; Convert json content to IDL objects.
;
; :Returns:
;   combination of list/orderedhash/dictionary/array/structure depending on
;   keywords passed
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     keyword for `JSON_PARSE`
;-
function mgnetresponse::json, _extra=e
  compile_opt strictarr

  return, json_parse(*self.content, _extra=e)
end


;= overload methods

function mgnetresponse::_overloadHelp, varname
  compile_opt strictarr

  format = string(strlen(varname) gt 15 ? '%s' : '%-15s', $
                  format='(%"(%%\"%s %%s  <STATUS=%%d>\")")')
  return, string(varname, obj_class(self), self.status_code, $
                 format=format)
end


function mgnetresponse::_overloadPrint
  compile_opt strictarr

  return, string(self.status_code, format='(%"<Response [%d]>")')
end


;= property access

pro mgnetresponse::getProperty, status_code=status_code, ok=ok, reason=reason
  compile_opt strictarr

  if (arg_present(status_code)) then status_code = self.status_code
  if (arg_present(ok)) then ok = self.status_code lt 300L or self.status_code ge 600L
  if (arg_present(reason)) then reason = mg_responsecode_message(self.status_code)
end


;= lifecycle methods

pro mgnetresponse::cleanup
  compile_opt strictarr

  ptr_free, self.content
end


function mgnetresponse::init, status_code=status_code, $
                              headers=headers, $
                              content=content
  compile_opt strictarr

  self.status_code = status_code
  self.content = ptr_new(content)

  return, 1
end


pro mgnetresponse__define
  compile_opt strictarr

  !null = { mgnetresponse, inherits IDL_Object, $
            status_code: 0L, $
            headers: obj_new(), $
            content: ptr_new() $
          }
end

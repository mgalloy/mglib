; docformat = 'rst'

;+
; Parses a C routine prototype.
;
; :Private:
;-


;+
; Parses a C routine's prototype into components. For example, the following
; prototype::
;
;   char *IDL_OutputFormatFunc(int type)
;
; into name of "IDL_OutputFormatFunc", `RETURN_TYPE` of "char *", and `PARAMS`
; of ["int type"].
;
; :Returns:
;   routine name as string
;
; :Params:
;   proto : in, required, type=string
;     C routine prototype specified as a string
;
; :Keywords:
;   params : out, optional, type=strarr
;     string array of parameter declarations
;   return_type : out, optional, type=string/long
;     return type of function as a SIZE type code if an IDL native type or
;     as C type specification if not
;   return_pointer : out, optional, type=boolean
;     set to a named variable to return whether the return value is a pointer
;-
function mg_parse_cprototype, proto, $
                              params=params, $
                              return_type=return_type, $
                              return_pointer=return_pointer
  compile_opt strictarr

  open_paren_pos = strpos(proto, '(', /reverse_search)
  close_paren_pos = strpos(proto, ')', /reverse_search)

  params = strmid(proto, $
                  open_paren_pos + 1L, $
                  close_paren_pos - open_paren_pos - 1L)
  params = strtrim(strsplit(params, ',', /extract), 2)

  return_type = mg_parse_cdeclaration(strmid(proto, 0, open_paren_pos), $
                                      name=name, pointer=return_pointer)

  return, name
end

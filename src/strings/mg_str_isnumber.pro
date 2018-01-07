; docformat = 'rst'

;+
; Returns whether `value` can be validly converted to the given type (float by
; default) -- even if conversion would be a loss of precision.
;
; :Uses:
;   mg_default
;
; :Returns:
;   `1B` if possible to convert, `0B` if not possible
;
; :Params:
;   value : in, required, type=string
;     string to check conversion of
;
; :Keywords:
;   type : in, optional, type=integer, default=4
;     type code as returned by `SIZE`
;-
function mg_str_isnumber, value, type=type
  compile_opt strictarr
  on_ioerror, not_number

  _type = mg_default(type, 4)

  !null = fix(value, type=_type)
  return, 1B

  not_number:
  return, 0B
end

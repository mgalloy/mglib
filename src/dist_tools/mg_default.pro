; docformat = 'rst'

;+
; Return a value or a default value if the value is not present.
;
; :Returns:
;   any
;
; :Params:
;   value : in, required, type=any
;     value that will be checked
;   default_value : in, required, type=any
;     default value if `value` is not present
;-
function mg_default, value, default_value
  compile_opt strictarr

  return, n_elements(value) eq 0L ? default_value : value
end

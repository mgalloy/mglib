; docformat = 'rst'

;+
; Determines if the argument is an array.
;
; :Returns:
;    1 if the argument is an array, 0 otherwise
;
; :Params:
;    arg : in, required, type=any
;       arg to test
;-
function mg_isarray, arg
  compile_opt strictarr

  return, size(arg, /n_dimensions) ne 0
end
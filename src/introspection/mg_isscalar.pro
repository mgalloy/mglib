; docformat = 'rst'

;+
; Determines if the argument is a scalar.
;
; :Returns:
;    1 if the argument is a scalar, 0 otherwise
;
; :Params:
;    arg : in, required, type=any
;       arg to test
;-
function mg_isscalar, arg
  compile_opt strictarr

  return, n_elements(arg) eq 1 && size(arg, /n_dimensions) eq 0
end
; docformat = 'rst'

;+
; Calculate the harmonic mean of an array of values.
;
; :Returns:
;   scalar of the same type as `x`, though integer types will be converted to
;   float
;
; :Params:
;   x : in, required, type=numeric array
;     array of values to find harmonic mean of
;-
function mg_harmonic_mean, x
  compile_opt strictarr

  return, n_elements(x) / total(1.0 / x, /preserve_type)
end

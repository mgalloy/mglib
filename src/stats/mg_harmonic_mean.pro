; docformat = 'rst'

;+
; Calculate the harmonic mean of an array of values. Defined to be 0.0 if any
; values of `x` are 0.
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

  if (mg_any(x eq 0)) then return, 0.0
  return, n_elements(x) / total(1.0 / x, /preserve_type)
end

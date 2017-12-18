; docformat = 'rst'

;+
; Calculate the L-p norm of `x`.
;
; :Returns:
;   float/double
;
; :Params:
;   x : in, required, type=float/double
;     values to take the norm of
;
; :Keywords:
;   p : in, optional, type=numeric >= 1/Inf
;     set to calculate the L-p norm; set `P` to `!values.f_infinity` to
;     calculate the L-infinity norm
;-
function mg_norm, x, p=p
  compile_opt strictarr

  _p = mg_default(p, 2L)
  return, finite(_p) ? (total(x^_p, /preserve_type)) ^ (1.0 / _p) : max(abs(x))
end

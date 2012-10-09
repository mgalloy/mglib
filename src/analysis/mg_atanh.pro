; docformat = 'rst'

;+
; Inverse hyperbolic tangent. Uses the formula:
;
; $$\text{atanh}(z) = \frac{\ln(\frac{1 + z}{1 - z})}{2}$$
;
; :Examples:
;    The arc hyperbolic sine function looks like::
;
;       IDL> x = 2. * findgen(1000) / 999. - 1.
;       IDL> plot, x, mg_atanh(x), xstyle=1
;
;    This should look like:
;
;    .. image:: atanh.png
;
; :Returns:
;    float, double, complex, or double complex depending on the input
;
; :Params:
;    z : in, required, type=numeric
;       input
;-
function mg_atanh, z
  compile_opt strictarr

  return, alog((1 + z) / (1 - z)) / 2.0
end

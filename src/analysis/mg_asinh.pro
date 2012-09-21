; docformat = 'rst'

;+
; Inverse hyperbolic sine. Uses the formula:
;
; $$\text{asinh}(z) = \ln(z + \sqrt{1 + z^2})$$
;
; :Examples:
;    The arc hyperbolic sine function looks like::
;
;       IDL> x = 10. * findgen(1000) / 999. - 5.
;       IDL> plot, x, mg_asinh(x), xstyle=1
;
;    This should look like:
;
;    .. image:: asinh.png
;
; :Returns:
;    float, double, complex, or double complex depending on the input 
;
; :Params:
;    z : in, required, type=numeric
;       input
;-
function mg_asinh, z
  compile_opt strictarr
  
  return, alog(z + sqrt(1 + z*z))
end

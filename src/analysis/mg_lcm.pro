; docformat = 'rst'

;+
; Find the least common multiple (LCM) for two positive integers.
;
; :Examples:
;    For example, try::
;
;       IDL> print, mg_lcm(3, 4)
;             12
;       IDL> print, mg_lcm(4, 6)
;             12
;
; :Returns:
;    integer
;
; :Params:
;    a : in, required, type=integer
;       first integer
;    b : in, required, type=integer
;       second integer
;-
function mg_lcm, a, b
  compile_opt strictarr
  on_error, 2

  if (n_params() ne 2) then message, 'incorrect number of arguments'

  return, abs(a) / mg_gcd(a, b) * abs(b)
end

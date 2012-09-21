; docformat = 'rst'

;+
; Calculate a mathematical combination.
;
; :Examples:
;    For example, the number of ways to choose 3 items from 5 items is::
;
;       IDL> print, mg_choose(5, 3)
;                           10
;
; :Returns:
;    long64
;
; :Params:
;    m : in, required, type=integer
;       number of items
;    n : in, required, type=integer
;       size of combination
;-
function mg_choose, m, n
  compile_opt strictarr
  
  return, round(exp(lngamma(m + 1.D) - lngamma(n + 1.D) - lngamma(m - n + 1.D)), /l64)
end

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
;
; :Keywords:
;    with_repetition : in, optional, type=boolean
;      set to allow repetition when choosing
;-
function mg_choose, m, n, with_repetition=with_repetition
  compile_opt strictarr

  if (keyword_set(with_repetition)) then return, mg_choose(m + n - 1, n)
  return, round(exp(lngamma(m + 1.D) - lngamma(n + 1.D) - lngamma(m - n + 1.D)), /l64)
end

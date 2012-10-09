; docformat = 'rst'

;+
; Calculate a mathematical permutation.
;
; :Returns:
;    long64
;
; :Params:
;    m : in, required, type=integer
;       number of items
;    n : in, required, type=integer
;       size of permutation
;-
function mg_permutation, m, n
  compile_opt strictarr

  return, round(exp(lngamma(m + 1.D) - lngamma(m - n + 1.D)), /l64)
end

; docformat = 'rst'

;+
; Returns an `n` by `n` array where every element is the euclidean distance to
; a fixed location.
;
; The fixed location is the center of the array if `CENTER` is set, i.e., the
; center pixel if there are an odd number of pixels or in the center of the four
; center pixels if there are an even number of pixels. If `CENTER` is not set,
; this location is the in location (0, 0) (for odd `n`) or (0.5, 0.5) (for even
; `n`).
;
; :Examples:
;   For example, try::
;
;     IDL> print, mg_dist(3, /center)
;           1.41421      1.00000      1.41421
;           1.00000      0.00000      1.00000
;           1.41421      1.00000      1.41421
;     IDL> print, mg_dist(4, /center)
;           2.12132      1.58114      1.58114      2.12132
;           1.58114     0.707107     0.707107      1.58114
;           1.58114     0.707107     0.707107      1.58114
;           2.12132      1.58114      1.58114      2.12132
;
; :Returns:
;   `fltarr(n, n)`
;
; :Params:
;   n : in, required, type=integer
;     size of required output
;
; :Keywords:
;   center : in, optional, type=boolean
;     set to 
;-
function mg_dist, n, center=center
  compile_opt strictarr

  x = findgen(n) + (n mod 2 eq 0 ? 0.5 : 0.0)
  if (keyword_set(center)) then x = shift(x, n / 2)
  x <= n - x
  x = rebin(x, n, n)
  return, sqrt(x^2 + (transpose(x))^2)
end

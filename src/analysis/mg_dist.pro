; docformat = 'rst'

;+
; Returns an `m` by `n` array where every element is the Euclidean distance to
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
;   `fltarr(m, n)`
;
; :Params:
;   m : in, required, type=integer
;     xsize, and ysize if `n` not provided, of required output
;   n : in, optional, type=integer, default=n
;     ysize of required output
;
; :Keywords:
;   center : in, optional, type=boolean
;     set to find distance from center of array
;   theta : out, optional, type="fltarr(m, n)"
;     set to a named variable to retrieve the angle, in radians, from a location
;     to the fixed location
;   degrees : in, optional, type=boolean
;     set to retrieve `THETA` in degrees
;-
function mg_dist, m, n, center=center, theta=theta, degrees=degrees
  compile_opt strictarr

  _n = n_elements(n) eq 0L ? m : n

  x = findgen(m) + (m mod 2 eq 0 ? 0.5 : 0.0) - m / 2
  if (~keyword_set(center)) then x = shift(x, m / 2)
  x = rebin(reform(x, m, 1), m, _n)

  y = findgen(_n) + (_n mod 2 eq 0 ? 0.5 : 0.0) - _n / 2
  if (~keyword_set(center)) then y = shift(y, _n / 2)
  y = rebin(reform(y, 1, _n), m, _n)

  if (arg_present(theta)) then begin
    theta = (2.0 * !pi + atan(y, x)) mod (2.0 * !pi)
    if (keyword_set(degrees)) then theta *= !radeg
  endif

  return, sqrt(x^2 + y^2)
end

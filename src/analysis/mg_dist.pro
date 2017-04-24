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
;     set to find distance from center of array
;   theta : out, optional, type="fltarr(n, n)"
;     set to a named variable to retrieve the angle, in radians, from a location
;     to the fixed location
;   degrees : in, optional, type=boolean
;     set to retrieve `THETA` in degrees
;-
function mg_dist, n, center=center, theta=theta, degrees=degrees
  compile_opt strictarr

  x = findgen(n) + (n mod 2 eq 0 ? 0.5 : 0.0) - n / 2
  if (~keyword_set(center)) then x = shift(x, n / 2)
  x = rebin(x, n, n)
  y = transpose(x)

  if (arg_present(theta)) then begin
    theta = (2.0 * !pi + atan(y, x)) mod (2.0 * !pi)
    if (keyword_set(degrees)) then theta *= !radeg
  endif

  return, sqrt(x^2 + y^2)
end

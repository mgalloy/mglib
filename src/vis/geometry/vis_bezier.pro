; docformat = 'rst'

;+
; Returns the Bezier curve between points. 
;
; :Examples:
;    Try the main-level example program at the end of this file::
;
;       IDL> .run vis_bezier
;
;    This should produce:
;
;    .. image:: bezier.png
;-


;+
; Computes the binomial coefficients for a given degree.
;
; :Returns:
;    fltarr(n + 1L)
;
; :Params:
;    n : in, required, type=long
;       degree of binomial coefficients, 0, 1, 2, ... n
;-
function vis_bezier_binomial, n
  compile_opt strictarr

  coeffs = lonarr(n + 1L)
  
  ; initialize (n choose 0) to be 1 and use recursive formula to calculate
  ; the rest of the coefficients: 
  ; 
  ;    (n choose i) = (n choose i - 1) * (n - i + 1) / i

  coeffs[0] = 1  
  for i = 1L, n do coeffs[i] = coeffs[i - 1L] * (n - i + 1L) / i
  
  return, coeffs
end


;+
; Returns the Bezier curve between points. 
;
; The returned Bezier curve will go through the first and last points, but the 
; intermediate points only indicate shape and direction so the curve is not 
; guaranteed to pass through them.
; 
; :Returns:
;    fltarr(2, npoints)
;
; :Params:
;    x : in, required, type=fltarr(n)
;       x-coordinates of control points
;    y : in, required, type=fltarr(n)
;       y-coordinates of control points
;    z : in, optional, type=fltarr(n)
;       z-coordinates of control points
; 
; :Keywords:
;    n_points : in, optional, type=long, default=20L
;       number of points
;-
function vis_bezier, x, y, z, n_points=npoints
  compile_opt strictarr
  on_error, 2
  
  _npoints = n_elements(npoints) eq 0L ? 20L : npoints
  t = reform(findgen(_npoints) / (_npoints - 1L), 1, _npoints)
  n = n_elements(x)
  bcoeffs = vis_bezier_binomial(n - 1L)
  
  sum = 0.0
  if (n_elements(z) eq 0L) then begin
    for i = 0L, n - 1L do begin
      sum += (bcoeffs[i] * (1. - t) ^ (n - i - 1L) * t ^ i) ## [x[i], y[i]]
    endfor
  endif else begin
    for i = 0L, n - 1L do begin
      sum += (bcoeffs[i] * (1. - t) ^ (n - i - 1L) * t ^ i) ## [x[i], y[i], z[i]]
    endfor
  endelse

  return, sum
end


; main-level example program

vis_window, xsize=5, ysize=5, /inches, /free
plot, findgen(11), /nodata, xstyle=5, ystyle=5, xmargin=[0, 0], ymargin=[0, 0]

r = 4L
n = 15L
t = findgen(n) / n * 2 * !pi
x = r * cos(t) + 5.
y = r * sin(t) + 5.

; outside circle
plots, [x, x[0]], [y, y[0]]

; spokes
for i = 0L, n - 1L do begin
  plots, vis_bezier([x[i], 0.5 * (x[(i + 2) mod n] - 5.) + 5., 5.], $
                    [y[i], 0.5 * (y[(i + 2) mod n] - 5.) + 5., 5.])
endfor

end
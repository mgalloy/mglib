; docformat = 'rst'

;+
; Creates a 2-dimensional spline curve through the given x- and y-coordinates.
;
; :Todo:
;    this should break down segments so that the x passed into SPL_INTERP is
;    always monotonically increasing
;
; :Examples:
;    A spline curve through some points can easily be computed::
;
;       IDL> pts = mg_spline([1, 3, 5], [1, 5, 3])
;
;    To display this curve::
;
;       IDL> plot, findgen(11), /nodata, xstyle=9, ystyle=9
;       IDL> plots, pts
;
;    See the main-level program at the end of this file for a more involved
;    example::
;
;       IDL> .run mg_spline
;-

;+
; Creates a 2-dimensional spline curve through the given x- and y-coordinates.
;
; :Returns:
;    fltarr(2, n) or dblarr(2, n)
;
; :Params:
;    x : in, required, type=numeric vector
;       x-coordinates of input points
;    y : in, required, type=numeric vector
;       y-coordinates of input points
;
; :Keywords:
;    n_points : in, optional, type=long, default=20L
;       number of points in output
;    _extra : in, optional, type=keywords
;       keywords to SPLINE_P
;-
function mg_spline, x, y, n_points=npoints, _extra=e
  compile_opt strictarr

  _npoints = n_elements(npoints) eq 0L ? 20L : npoints
  _x = reform(x)
  _y = reform(y)

  d = mg_arclength(_x, _y)
  _interval = d / (_npoints - 1L)
  spline_p, _x, _y, x2, y2, interval=_interval, _extra=e

  return, transpose([[[x2], [y2]]])
end


; main-level example program

mg_window, xsize=5, ysize=5, /inches, /free
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
  plots, mg_spline([x[i], 0.5 * (x[(i + 1) mod n] - 5.) + 5., 5.], $
                   [y[i], 0.5 * (y[(i + 1) mod n] - 5.) + 5., 5.])
endfor

end
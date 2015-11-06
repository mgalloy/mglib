; docformat = 'rst'

;+
; Find the indices of the vertices of the convex hull for a set of (x, y)
; points.
;
; :Returns:
;   `lonarr`
;
; :Params:
;   x : in, required, type=fltarr
;     x-coordinates of a point cloud
;   y : in, required, type=fltarr
;     y-coordinates of a point cloud
;-
function mg_convex_hull, x, y
  compile_opt strictarr

  triangulate, x, y, triangles, hull
  return, hull
end


; main-level example program

n = 20
x = randomu(seed, n)
y = randomu(seed, n)

hull_indices = mg_convex_hull(x, y)

device, get_decomposed=odec
device, decomposed=1

win_size = 500L
window, title='Convex hull', xsize=win_size, ysize=win_size, /free
plot, [0, 1], [0, 1], /nodata, background='ffffff'x, color='000000'x


polyfill, x[hull_indices], y[hull_indices], color='e0e0e0'x
plots, x[[hull_indices, hull_indices[0L]]], $
       y[[hull_indices, hull_indices[0L]]], $
       color='c0c0c0'x, thick=2.0

plots, x, y, psym=1, color='000000'x

device, decomposed=odec

end
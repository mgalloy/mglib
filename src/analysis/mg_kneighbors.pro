; docformat = 'rst'

;+
; Naive nearest neighbor implementation. This should work reasonably for 
;
; :Returns:
;   `lonarr(k, predict)` where values are indices into the rows of `x`
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     dataset to search for `k` nearest neighbors
;   xi : in, required, type="fltarr(n_features, n_predict)"
;     rows to find `k` nearest neighbors (in rows of `x`) for
;   k : in, required, type=integer
;     number of neighbors to find
;
; :Keywords:
;   metric : in, optional, type=string, default='euclidean'
;     metric to use: euclidean or manhattan
;-
function mg_kneighbors, x, xi, k, metric=metric
  compile_opt strictarr
  on_error, 2

  _k = mg_default(k, 1L)
  _metric = strlowcase(mg_default(metric, 'euclidean'))

  x_dims = size(x, /dimensions)
  xi_dims = size(xi, /dimensions)

  ind = lonarr(_k, xi_dims[1])

  for i = 0L, xi_dims[1] - 1L do begin
    case _metric of
      'euclidean': d = total((x - rebin(xi[*, i], xi_dims[0], x_dims[1]))^2, 1)
      'manhattan': d = total(abs(x - rebin(xi[*, i], xi_dims[0], x_dims[1])), 1)
      else: message, 'unknown metric ' + _metric
    endcase
    ind[*, i] = mg_n_smallest(d, k)
  endfor

  return, ind
end


; main-level example program

n_pts = 100
n_check_pts = 5
n_dims = 2
k = 3

pts = randomu(seed, n_dims, n_pts)
check = randomu(seed, n_dims, n_check_pts)

clock_id = tic()
; ind = lonarr(k, n_check_pts)
ind = mg_kneighbors(pts, check, k)
t = toc(clock_id)
print, t, format='(%"execution time: %0.2f sec")'

device, get_decomposed=odec
device, decomposed=0
tvlct, rgb, /get
loadct, 5

mg_window, xsize=5, ysize=5, /inches, title='Nearest neighbors'
plot, reform(pts[0, *]), reform(pts[1, *]), $
      psym=mg_usersym(/circle), symsize=0.25, $
      xrange=[0.0, 1.0], xstyle=9, $
      yrange=[0.0, 1.0], ystyle=9, $
      /isotropic
plots, reform(check[0, *]), reform(check[1, *]), $
       psym=mg_usersym(/circle, /fill), symsize=1.0, $
       color=150
plots, pts[0, mg_flatten(ind)], pts[1, mg_flatten(ind)], $
       psym=mg_usersym(/circle), symsize=2.0, $
       color=150

device, decomposed=odec
tvlct, rgb

end

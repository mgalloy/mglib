; docformat = 'rst'

;+
; K-Means clustering
;
; :Categories:
;   unsupervised
;
; :Properties:
;   n_clusters : type=integer
;     number of clusters to find, default=8
;   n_iterations : type=integer
;     number of interations to perform, default=20
;   n_initializations : type=integer
;     number of times to fit the data with new random initialization, choosing
;     the best of the fits, i.e., the one which minimizes the sum of the
;     variances of distances of the points in a cluster to their center;
;     default=10
;-

;= API

;+
; Use training set of data `x` and targets `y` to train the model.
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     data to learn on
;   y : in, required, type=lonarr(n_samples)
;     unused
;
; :Keywords:
;   seed : in, out, optional, type=integer
;     random number generator seed
;-
pro mg_kmeans::fit, x, y, seed=seed
  compile_opt strictarr

  self->mg_classifier::fit, x, y

  *self._centers = mg_kmeans_centers(x, $
                                     n_clusters=self.n_clusters, $
                                     n_iterations=self.n_iterations, $
                                     n_initializations=self.n_initializations, $
                                     double=self.double, $
                                     seed=seed)
end


;+
; Use previous training with `fit` method to predict targets for given data `x`.
;
; :Returns:
;   `lonarr(n_samples)`
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     data to predict targets for
;   y : in, optional, type=lonarr(n_samples)
;     unused
;
; :Keywords:
;   score : out, optional, type=float
;     unused
;-
function mg_kmeans::predict, x, y, score=score
  compile_opt strictarr

  return, reform(cluster(x, *self._centers, n_clusters=self.n_clusters, double=self.double))
end


;= overload methods

function mg_kmeans::_overloadHelp, varname
  compile_opt strictarr

  _type = 'KMeans'
  _specs = string(self.n_clusters, format='(%"<%d clusters>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_kmeans::getProperty, n_clusters=n_clusters, $
                            n_iterations=n_iterations, $
                            n_initializations=n_initializations, $
                            double=double, $
                            centers=centers, $
                            fit_parameters=fit_parameters, $
                            _ref_extra=e
  compile_opt strictarr

  if (arg_present(n_clusters)) then n_clusters = self.n_clusters
  if (arg_present(n_iterations)) then n_iterations = self.n_iterations
  if (arg_present(n_initializations)) then n_initializations = self.n_initializations
  if (arg_present(double)) then double = self.double
  if (arg_present(centers)) then centers = *self._centers
  if (arg_present(fit_parameters)) then fit_parameters = *self._centers

  if (n_elements(e) gt 0L) then self->mg_classifier::getProperty, _extra=e
end


pro mg_kmeans::setProperty, fit_parameters=fit_parameters, _extra=e
  compile_opt strictarr

  if (n_elements(fit_parameters) gt 0L) then *self._centers = fit_parameters

  if (n_elements(e) gt 0L) then self->mg_classifier::setProperty, _extra=e
end


;= lifecycle methods

pro mg_kmeans::cleanup
  compile_opt strictarr

  ptr_free, self._centers
  self->mg_classifier::cleanup
end


function mg_kmeans::init, n_clusters=n_clusters, $
                          n_iterations=n_iterations, $
                          n_initializations=n_initializations, $
                          double=double, $
                          _extra=e
  compile_opt strictarr

  if (~self->mg_classifier::init(_extra=e)) then return, 0

  self.type = 'unsupervised'
  self.name = 'KMeans'

  self.n_clusters = mg_default(n_clusters, 8)
  self.n_iterations = mg_default(n_iterations, 20)
  self.n_initializations = mg_default(n_initializations, 10)
  self.double = keyword_set(double)

  self._centers = ptr_new(/allocate_heap)

  return, 1
end


pro mg_kmeans__define
  compile_opt strictarr

  !null = {mg_kmeans, inherits mg_classifier, $
           n_clusters: 0L, $
           n_iterations: 0L, $
           n_initializations: 0L, $
           double: 0B, $
           _centers: ptr_new() $
          }
end


; main-level example program

;seed = 1L

x = mg_make_blobs(3, $
                  sizes=50, $
                  scales=0.075, $
                  centers=[[0.75, 0.80], [0.30, 0.60], [0.55, 0.30]], $
                  seed=seed)

kmeans = mg_kmeans(n_clusters=3, n_iterations=50, /double)

kmeans->fit, x, seed=seed

colors = mg_rgb2index(rebin(reform(lindgen(kmeans.n_clusters) * (255 / kmeans.n_clusters), kmeans.n_clusters, 1), kmeans.n_clusters, 3))
all_symbols = [1, 4, 5, 6, 7]
symbols = all_symbols[lindgen(kmeans.n_clusters) mod n_elements(all_symbols)]

window, xsize=800, ysize=400, title='Clustering', /free
!p.multi = [0, 2, 1]
device, get_decomposed=odec
device, decomposed=1

plot, x[0, *], x[1, *], psym=mg_usersym(/circle, color='808080'x), symsize=0.5, $
      xrange=[0.0, 1.0], yrange=[0.0, 1.0], xstyle=1, ystyle=1, $
      color='000000'x, background='ffffff'x

labels = kmeans->predict(x)

plot, x[0, *], x[1, *], psym=4, /nodata, $
      xrange=[0.0, 1.0], yrange=[0.0, 1.0], xstyle=1, ystyle=1, $
      color='000000'x, background='ffffff'x
for c = 0L, kmeans.n_clusters - 1L do begin
  ind = where(labels eq c, count)

  print, c, count, format='(%"class %d: %d points")'
  plots, kmeans.centers[0, c], kmeans.centers[1, c], $
         psym=1, color=colors[c], symsize=3.0, thick=3.0
  if (count gt 0L) then begin
    plots, x[0, ind], x[1, ind], psym=symbols[c], color=colors[c]
  endif
endfor

!p.multi = 0
device, decomposed=odec

obj_destroy, kmeans

end

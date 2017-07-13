; docformat = 'rst'

;+
; K-Means clustering
;
; :Categories:
;   unsupervised
;
; :Properties:
;   n_clusters : type=integer
;     number of clusters to find
;   n_iterations : type=integer
;     number of interations to perform
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
;-
pro mg_kmeans::fit, x, y
  compile_opt strictarr

  *self._centers = clust_wts(x, $
                             n_clusters=self.n_clusters, $
                             n_iterations=self.n_iterations, $
                             double=self.double)
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

  return, cluster(x, *self._centers, n_clusters=self.n_clusters, double=self.double)
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
                            double=double, $
                            centers=centers, $
                            _ref_extra=e
  compile_opt strictarr

  if (arg_present(n_clusters)) then n_clusters = self.n_clusters
  if (arg_present(n_iterations)) then n_iterations = self.n_iterations
  if (arg_present(double)) then double = self.double
  if (arg_present(centers)) then centers = *self._centers

  if (n_elements(e) gt 0L) then self->mg_estimator::getProperty, _extra=e
end


;= lifecycle methods

pro mg_kmeans::cleanup
  compile_opt strictarr

  ptr_free, self._centers
  self->mg_estimator::cleanup
end


function mg_kmeans::init, n_clusters=n_clusters, $
                          n_iterations=n_iterations, $
                          double=double, $
                          _extra=e
  compile_opt strictarr

  if (~self->mg_estimator::init(_extra=e)) then return, 0

  self.type = 'unsupervised'

  self.n_clusters = mg_default(n_clusters, 8)
  self.n_iterations = mg_default(n_iterations, 20)
  self.double = keyword_set(double)

  self._centers = ptr_new(/allocate_heap)

  return, 1
end


pro mg_kmeans__define
  compile_opt strictarr

  !null = {mg_kmeans, inherits mg_estimator, $
           n_clusters: 0L, $
           n_iterations: 0L, $
           double: 0B, $
           _centers: ptr_new() $
          }
end


; main-level example program

n = 50

c1 = 0.5 * randomn(seed, 2, n)
c1 += rebin(reform([7.5, 8.0], 2, 1), 2, n)

c2 = 0.5 * randomn(seed, 2, n)
c2 += rebin(reform([3.0, 6.0], 2, 1), 2, n)

c3 = 0.5 * randomn(seed, 2, n)
c3 += rebin(reform([5.5, 3.0], 2, 1), 2, n)

x = [[c1], [c2], [c3]] / 10.0

kmeans = mg_kmeans(n_clusters=3, n_iterations=50, /double)

kmeans->fit, x

colors = ['404040'x, '707070'x, 'a0a0a0'x]
symbols = [1, 4, 5]

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

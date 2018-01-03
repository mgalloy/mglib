; docformat = 'rst'

;+
; K-Means clustering centers.
;
; This uses the algorithm from `CLUST_WTS`, but I would like to change this to a
; more robust implementation.
;
; :Returns:
;   fltarr/dblarr(n_features, n_clusters)
;
; :Params:
;   x : in, required, type="arr(n_features, n_samples)"
;     numeric array
;
; :Keywords:
;   double : in, optional, type=boolean
;     set to do calculations in double precision
;   n_clusters : in, optional, type=integer, default=n_samples
;     number of clusters to find
;   n_iterations : in, optional, type=integer, default=20
;     number of iterations
;   n_initializations : in, optional, type=integer, default=10
;     number of times to run the algorithm with different initializations
;   feature_weights : in, optional, type=fltarr(n_features)
;     weights for each feature, default is all features an equal weight
;   seed : in, out, optional, type=integer
;     seed for random number generator
;-
function mg_kmeans_centers, x, $
                            double=double, $
                            n_clusters=n_clusters, $
                            n_iterations=n_iterations, $
                            n_initializations=n_initializations, $
                            feature_weights=feature_weights, $
                            seed=seed
  compile_opt strictarr
  on_error, 2

  n_dims = size(x, /n_dimensions)
  dims = size(x, /dimensions)
  type = size(x, /type)

  if (n_dims ne 2) then message, 'input array must be 2-dimensional'

  n_features = dims[0]
  n_samples = dims[1]

  _double = keyword_set(double) || type eq 5
  zero = _double ? 0.0D : 0.0

  _n_clusters = mg_default(n_clusters, n_samples)
  _n_iterations = mg_default(n_iterations, 20)
  _n_initializations = mg_default(n_initializations, 10)
  _feature_weights = mg_default(feature_weights, fltarr(n_features) + 1.0 + zero)

  learning = [0.5, 0.1] + zero
  delta_learning_rate = (learning[0] - learning[1]) / _n_iterations

  best_variance = 1000000.0

  for t = 0L, _n_initializations - 1L do begin
    learning_rate = learning[0]

    ; normalized uniformly random cluster centers
    centers = randomu(seed, n_features, _n_clusters) + zero
    centers /= rebin(reform(total(centers, 2, /preserve_type), $
                            n_features, 1), $
                     n_features, _n_clusters)
    centers *= rebin(reform(_feature_weights, n_features, 1), n_features, n_clusters)

    temp_col = replicate(1.0 + zero, 1, _n_clusters)
    temp_row = replicate(1.0 + zero, 1, n_features)
    count = lonarr(_n_clusters)

    for i = 0L, _n_iterations - 1L do begin
      for s = 0L, n_samples - 1L do begin
        v = x[*, s] # temp_col - centers
        d = temp_row # abs(v)
        minimal = where(d eq min(d))
        count[minimal] += 1
        centers[*, minimal] += learning_rate * v[*, minimal]
      endfor
      learning_rate -= delta_learning_rate
    endfor

    labels = cluster(x, centers, n_clusters=_n_clusters, double=double)
    variances = replicate(zero, n_clusters)
    for c = 0L, n_clusters - 1L do begin
      ind = where(labels eq c, count)
      if (count gt 0L) then begin
        ctrs = rebin(reform(centers[*, c], n_features, 1), n_features, count)
        variances[c] = variance(sqrt(total((x[*, ind] - ctrs) ^ 2, 1, /preserve_type)), $
                                double=double)
      endif
    endfor
    variance = total(variances, /preserve_type)
    if (variance lt best_variance) then begin
      best_variance = variance
      best_centers = centers
    endif
  endfor

  return, best_centers
end

; docformat = 'rst'

;+
; Nearest neighbor classifier.
;
; :Categories:
;   classifier
;
; :Properties:
;   n_neighbors : type=integer, default=1
;     number of neighbors to find
;-

;= API

;+
; Use training set of data `x` and targets `y` to train the model.
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     data to learn on
;   y : in, required, type=lonarr(n_samples)
;     results for `x` data; values must be -1 or 1
;-
pro mg_kneighborsegressor::fit, x, y
  compile_opt strictarr

  *self.x = x
  *self.y = y
end


;+
; Use previous training with `fit` method to predict targets for given data `x`.
;
; :Returns:
;   `lonarr(n_samples)`
;
; :Params:
;   x : in, required, type=fltarr(n_features, n_samples)
;     data to predict targets for
;   y : in, optional, type=lonarr(n_samples)
;     optional y-values; needed to get score; values must be -1 or 1
;
; :Keywords:
;   score : out, optional, type=float
;     if `y` was specified, set to a named variable to retrieve a coefficient
;     of determination, r^2,
;-
function mg_kneighborsegressor::predict, x, y, score=score
  compile_opt strictarr

  ; find indices of nearest self.n_neighbors neighbors in *self.x...
  neighbor_indices = mg_kneighbors(*self.x, x, self.n_neighbors)

  ; ...then average neighbors together for each y_predict element
  y_predict = mean((*self.y)[neighbor_indices], dimension=1)

  if (arg_present(score) && n_elements(y) gt 0) then begin
    score = self->_r2_score(y, y_predict)
  endif

  return, y_predict
end


;= property access

pro mg_kneighborsegressor::getProperty, n_neighbors=n_neighbors, $
                                        _ref_extra=e
  compile_opt strictarr

  if (arg_present(n_neighbors)) then n_neighbors = self.n_neighbors

  if (n_elements(e) gt 0L) then self->mg_regressor::getProperty, _extra=e
end


;= lifecycle methods

pro mg_kneighborsegressor::cleanup
  compile_opt strictarr

  ptr_free, self.x, self.y
  self->mg_regressor::cleanup
end


function mg_kneighborsegressor::init, n_neighbors=n_neighbors, _extra=e
  compile_opt strictarr

  if (~self->mg_regressor::init(_extra=e)) then return, 0

  self.n_neighbors = mg_default(n_neighbors, 1)
  self.x = ptr_new(/allocate_heap)
  self.y = ptr_new(/allocate_heap)

  return, 1
end


pro mg_kneighborsegressor__define
  compile_opt strictarr

  !null = {mg_kneighborsegressor, inherits mg_regressor, $
           n_neighbors: 0L, $
           x: ptr_new(), $
           y: ptr_new() $
          }
end


; main-level example program

; TODO: find example...

knr = mg_kneighborsegressor(n_neighbors=3)
obj_destroy, knr

end

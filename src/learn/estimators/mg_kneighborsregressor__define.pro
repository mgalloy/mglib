; docformat = 'rst'

;+
; Nearest neighbor regressor.
;
; :Categories:
;   regressor
;
; :Properties:
;   n_neighbors : type=integer
;     number of neighbors to find, defaults to 1
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
pro mg_kneighborsregressor::fit, x, y
  compile_opt strictarr

  *self._x = x
  *self._y = y
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
;     optional y-values; needed to get score; values must be -1 or 1
;
; :Keywords:
;   score : out, optional, type=float
;     if `y` was specified, set to a named variable to retrieve a coefficient
;     of determination, r^2,
;-
function mg_kneighborsregressor::predict, x, y, score=score
  compile_opt strictarr

  ; find indices of nearest self.n_neighbors neighbors in *self._x...
  neighbor_indices = mg_kneighbors(*self._x, x, self.n_neighbors)

  ; ...then average neighbors together for each y_predict element
  y_predict = mean((*self._y)[neighbor_indices], dimension=1)

  if (arg_present(score) && n_elements(y) gt 0) then begin
    score = self->_r2_score(y, y_predict)
  endif

  return, y_predict
end


;= overload methods

function mg_kneighborsregressor::_overloadHelp, varname
  compile_opt strictarr

  _type = 'KNR'
  _specs = string(self.n_neighbors, format='(%"<%d neighbors>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_kneighborsregressor::getProperty, n_neighbors=n_neighbors, $
                                        fit_parameters=fit_parameters, $
                                        _ref_extra=e
  compile_opt strictarr

  if (arg_present(n_neighbors)) then n_neighbors = self.n_neighbors
  if (arg_present(fit_parameters)) then begin
    fit_parameters = {x: *self._x, y: *self._y}
  endif

  if (n_elements(e) gt 0L) then self->mg_regressor::getProperty, _extra=e
end


pro mg_kneighborsregressor::setProperty, fit_parameters=fit_parameters, _extra=e
  compile_opt strictarr

  if (n_elements(fit_parameters) gt 0L) then begin
    *self._x = fit_parameters.x
    *self._y = fit_parameters.y
  endif

  if (n_elements(e) gt 0L) then self->mg_estimator::setProperty, _extra=e
end


;= lifecycle methods

pro mg_kneighborsregressor::cleanup
  compile_opt strictarr

  ptr_free, self._x, self._y
  self->mg_regressor::cleanup
end


function mg_kneighborsregressor::init, n_neighbors=n_neighbors, _extra=e
  compile_opt strictarr

  if (~self->mg_regressor::init(_extra=e)) then return, 0

  self.n_neighbors = mg_default(n_neighbors, 1)
  self._x = ptr_new(/allocate_heap)
  self._y = ptr_new(/allocate_heap)

  return, 1
end


pro mg_kneighborsregressor__define
  compile_opt strictarr

  !null = {mg_kneighborsregressor, inherits mg_regressor, $
           n_neighbors: 0L, $
           _x: ptr_new(), $
           _y: ptr_new() $
          }
end


; main-level example program

wave = mg_learn_dataset('wave', n_samples=75)
mg_train_test_split, wave.data, wave.target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test

knr = mg_kneighborsregressor(n_neighbors=3)
knr->fit, x_train, y_train
y_predict = knr->predict(x_test, y_test, score=r2)
print, r2, format='(%"r^2: %f")'
obj_destroy, knr

end

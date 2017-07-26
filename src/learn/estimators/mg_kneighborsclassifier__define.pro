; docformat = 'rst'

;+
; Nearest neighbor classifier.
;
; :Categories:
;   classifier
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
pro mg_kneighborsclassifier::fit, x, y
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
;     set to a named variable to retrieve a score if `y` was specified
;-
function mg_kneighborsclassifier::predict, x, y, score=score
  compile_opt strictarr

  dims = size(x, /dimensions)
  n_samples_predict = dims[1]
  y_predict = lonarr(n_samples_predict)

  ; find indices of nearest self.n_neighbors neighbors in *self._x...
  neighbor_indices = mg_kneighbors(*self._x, x, self.n_neighbors)

  for s = 0L, dims[1] - 1L do begin
    ; ...and look up the *self._y values for them, selecting the most common
    y_predict[s] = mg_mode((*self._y)[neighbor_indices[*, s]])
  endfor

  if (arg_present(score) && n_elements(y) gt 0) then begin
    score = total(y_predict eq y, /integer) / float(n_elements(y))
  endif

  return, y_predict
end


;= overload methods

function mg_kneighborsclassifier::_overloadHelp, varname
  compile_opt strictarr

  _type = 'KNC'
  _specs = string(self.n_neighbors, format='(%"<%d neighbors>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_kneighborsclassifier::getProperty, n_neighbors=n_neighbors, $
                                          fit_parameters=fit_parameters, $
                                          _ref_extra=e
  compile_opt strictarr

  if (arg_present(n_neighbors)) then n_neighbors = self.n_neighbors
  if (arg_present(fit_parameters)) then begin
    fit_parameters = {x: *self._x, y: *self._y}
  endif

  if (n_elements(e) gt 0L) then self->mg_estimator::getProperty, _extra=e
end


pro mg_kneighborsclassifier::setProperty, fit_parameters=fit_parameters, _extra=e
  compile_opt strictarr

  if (n_elements(fit_parameters) gt 0L) then begin
    *self._x = fit_parameters.x
    *self._y = fit_parameters.y
  endif

  if (n_elements(e) gt 0L) then self->mg_estimator::setProperty, _extra=e
end


;= lifecycle methods

pro mg_kneighborsclassifier::cleanup
  compile_opt strictarr

  ptr_free, self._x, self._y
  self->mg_estimator::cleanup
end


function mg_kneighborsclassifier::init, n_neighbors=n_neighbors, _extra=e
  compile_opt strictarr

  if (~self->mg_estimator::init(_extra=e)) then return, 0

  self.type = 'classifier'

  self.n_neighbors = mg_default(n_neighbors, 1)
  self._x = ptr_new(/allocate_heap)
  self._y = ptr_new(/allocate_heap)

  return, 1
end


pro mg_kneighborsclassifier__define
  compile_opt strictarr

  !null = {mg_kneighborsclassifier, inherits mg_estimator, $
           n_neighbors: 0L, $
           _x: ptr_new(), $
           _y: ptr_new() $
          }
end


; main-level example program

; load iris data
iris = mg_learn_dataset('iris')

; split the dataset into training and test data
seed = 0L
mg_train_test_split, iris.data, iris.target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test, $
                     test_size=0.2, $
                     seed=seed

; instantitate K-nearest neighbors model
p = mg_kneighborsclassifier(n_neighbors=3)
help, p

; train the model using the training data
clock_id = tic('mg_kneighborsclassifier')
p->fit, x_train, y_train
t = toc(clock_id)

; find results for the test data
y_results = p->predict(x_test, y_test, score=score)

print, t * 1000.0, format='(%"\nExecution time: %0.1f msec")'
print, score * 100.0, format='(%"Prediction score: %0.1f\%")'

cmatrix = mg_confusion_matrix(y_test, y_results, classes=classes)
print, '# Confusion matrix'
print, cmatrix

end

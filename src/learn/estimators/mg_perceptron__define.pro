; docformat = 'rst'

;+
; Perceptron binary classifier
;
; [1]: http://www.jeannicholashould.com/what-i-learned-implementing-a-classifier-from-scratch.html
; [2]: https://github.com/rasbt/python-machine-learning-book/blob/master/code/ch02/ch02.ipynb
;
; :Categories:
;   binary classifier
;
; :Properties:
;   max_iterations : type=long
;     maximum number of iterations to perform in `fit`
;   learning_rate : type=float
;     learning rate from 0.0 to 1.0
;   weights : type=fltarr
;     weights for each feature
;   bias : type=float
;     bias value
;   errors : type=lonarr
;     number of misclassifications in each iteration
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
pro mg_perceptron::fit, x, y
  compile_opt strictarr

  dims = size(x, /dimensions)
  n_features = dims[0]
  n_samples = dims[1]

  *self._weights = fltarr(n_features)
  self._bias = 0.0
  *self._errors = lonarr(self.max_iterations)
  self._n_iterations = 0L

  for i = 0L, self.max_iterations - 1L do begin
    self._n_iterations += 1L
    errors = 0L
    for s = 0L, n_samples - 1L do begin
      xi = reform(x[*, s], n_features, 1)
      update = (self.learning_rate * (y[s] - self->predict(xi)))[0]
      *self._weights += update * xi
      self._bias     += update
      (*self._errors)[i] += long(update ne 0.0)
    endfor

    ; can't vectorize the above loop because weights change with each iteration
    ; of the loop; if you computed update as a matrix, the entire calculation
    ; would use the same weights/bias

    ; update = self.learning_rate * (y - self.predict(x))
    ; *self._weights += x # update
    ; self._bias     += total(update, /preserve_type)
    ; (*self._errors)[i] = total(update ne 0.0, /integer)

    if ((*self._errors)[i] eq 0L) then break
  endfor
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
function mg_perceptron::predict, x, y, score=score
  compile_opt strictarr

  y_predict = 2L * ((reform(*self._weights # x) + self._bias) ge 0.0) - 1L
  if (arg_present(score) && n_elements(y) gt 0) then begin
    score = total(y_predict eq y, /integer) / float(n_elements(y))
  endif
  return, y_predict
end


;= overload methods

function mg_perceptron::_overloadHelp, varname
  compile_opt strictarr

  _type = 'PER'
  _specs = string(self.max_iterations, self.learning_rate, $
                  format='(%"<max interations: %d, learning rate: %0.2f>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_perceptron::getProperty, max_iterations=max_iterations, $
                                learning_rate=learning_rate, $
                                weights=weights, $
                                bias=bias, $
                                errors=errors, $
                                fit_parameters=fit_parameters, $
                                _ref_extra=e
  compile_opt strictarr

  if (arg_present(max_iterations)) then max_iterations = self.max_iterations
  if (arg_present(learning_rate)) then learning_rate = self.learning_rate
  if (arg_present(weights)) then weights = *self._weights
  if (arg_present(bias)) then bias = self._bias
  if (arg_present(errors)) then errors = (*self._errors)[0:self._n_iterations - 1L]
  if (arg_present(fit_parameters)) then begin
    fit_parameters = {weights: *self._weights, $
                      bias: self._bias, $
                      errors: (*self._errors)[0:self._n_iterations - 1L]}
  endif

  if (n_elements(e) gt 0L) then self->mg_estimator::getProperty, _extra=e
end


pro mg_perceptron::setProperty, max_iterations=max_iterations, $
                                learning_rate=learning_rate, $
                                fit_parameters=fit_parameters, $
                                _extra=e
  compile_opt strictarr

  if (n_elements(max_iterations) gt 0L) then self.max_iterations = max_iterations
  if (n_elements(learning_rate) gt 0L) then self.learning_rate = learning_rate
  if (n_elements(fit_parameters) gt 0L) then begin
    *self._weights = fit_parameters.weights
    self._bias = fit_parameters.bias
    (*self._errors)[0:n_elements(fit_parameters.errors) - 1L] = fit_parameters.errors
  endif

  if (n_elements(e) gt 0L) then self->mg_estimator::setProperty, _extra=e
end


;= lifecycle methods

pro mg_perceptron::cleanup
  compile_opt strictarr

  ptr_free, self._weights, self._errors
  self->mg_estimator::cleanup
end


function mg_perceptron::init, max_iterations=max_iterations, $
                              learning_rate=learning_rate, $
                              _extra=e
  compile_opt strictarr

  if (~self->mg_estimator::init(_extra=e)) then return, 0

  self.type = 'binary classifier'

  self._weights = ptr_new(/allocate_heap)
  self._errors = ptr_new(/allocate_heap)

  _max_iterations = mg_default(max_iterations, 10L)
  _learning_rate = mg_default(learning_rate, 0.01)
  self->setProperty, max_iterations=_max_iterations, $
                     learning_rate=_learning_rate, $
                     _extra=e

  return, 1
end


pro mg_perceptron__define
  compile_opt strictarr

  !null = {mg_perceptron, inherits mg_estimator, $
           max_iterations: 0L, $
           learning_rate: 0.0, $
           _n_iterations: 0L, $
           _bias: 0.0, $
           _weights: ptr_new(), $
           _errors: ptr_new() $
          }
end


; main-level example program

; load iris data
iris = mg_learn_dataset('iris')

; pick two of the three species: 0, 1, or 2
species = [0, 1]

; the 150 samples are equally split 50/50/50 into the different species and
; the samples are in order by target
ind = [lindgen(50) + 50 * species[0], lindgen(50) + 50 * species[1]]
data = iris.data[*, ind]
target = 2 / (species[1] - species[0]) * (iris.target[ind] - species[0]) - 1L  ; change to -1 and 1
target_names = iris.target_names[species]

; split the dataset into training and test data
;seed = 0L
mg_train_test_split, data, target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test, $
                     test_size=0.2, $
                     seed=seed

; instantiate Perceptron model
p = mg_perceptron(max_iterations=20)

; train the model using the training data
clock_id = tic('mg_perceptron')
p->fit, x_train, y_train
t = toc(clock_id)

; find results for the test data
y_results = p->predict(x_test, y_test, score=score)

print, target_names, format='(%"\n# Results for %s vs %s\n")'

for s = 0L, n_elements(y_test) - 1L do begin
  if (y_results[s] eq y_test[s]) then begin
    print, s, target_names[y_results[s] eq 1], $
           format='(%"%3d: results match, both: %s")'
  endif else begin
    print, s, target_names[y_results[s] eq 1], $
              target_names[y_test[s] eq 1], $
              format='(%"%3d: incorrect prediction: %s, truth: %s")'
  endelse
endfor

print, t * 1000.0, format='(%"\nExecution time: %0.1f msec")'
print, score * 100.0, format='(%"Prediction score: %0.1f\%")'
fmt = strjoin(strarr(p.max_iterations) + '%d', ' ')
print, p.errors, format='(%"Errors per iteration: ' + fmt + '")'

cmatrix = mg_confusion_matrix(y_test, y_results, classes=classes)
c = (classes + 1) / 2
print, cmatrix[0, 0], target_names[c[0]], $
       format='(%"true negatives : %d (true id of %s)")'
print, cmatrix[1, 0], target_names[c[[0, 1]]], $
       format='(%"false negatives: %d (predicted %s, but was %s)")'
print, cmatrix[1, 1], target_names[c[1]], $
       format='(%"true positives : %d (true id of %s)")'
print, cmatrix[0, 1], target_names[c[[1, 0]]], $
       format='(%"false positives: %d (predicted %s, but was %s)")'

print

print, format='(%"\n# Fit\n")'
print, p.bias, format='(%"bias: %0.2f")'
weights = p.weights
for w = 0L, n_elements(iris.feature_names) - 1L do begin
  print, iris.feature_names[w], weights[w], format='(%"%-20s: %0.2f")'
endfor

end

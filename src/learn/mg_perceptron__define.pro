; docformat = 'rst'

;+
; Perceptron binary classifier
;
; [1]: http://www.jeannicholashould.com/what-i-learned-implementing-a-classifier-from-scratch.html
; [2]: https://github.com/rasbt/python-machine-learning-book/blob/master/code/ch02/ch02.ipynb
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
;   y : in, required, type=fltarr(n_samples)
;     results for `x` data
;-
pro mg_perceptron::fit, x, y
  compile_opt strictarr

  dims = size(x, /dimensions)
  n_features = dims[0]
  n_samples = dims[1]

  *self.weights = fltarr(n_features)
  self.bias = 0.0
  *self.errors = lonarr(self.max_iterations)

  for i = 0L, self.max_iterations - 1L do begin
    errors = 0L
    for s = 0L, n_samples - 1L do begin
      xi = reform(x[*, s], n_features, 1)
      update = (self.learning_rate * (y[s] - self->predict(xi)))[0]
      *self.weights += update * xi
      self.bias     += update
      (*self.errors)[i] += long(update ne 0.0)
    endfor

    ; can't vectorize the above loop because weights change with each iteration
    ; of the loop; if you computed update as a matrix, the entire calculation
    ; would use the same weights/bias

    ; update = self.learning_rate * (y - self.predict(x))
    ; *self.weights += x # update
    ; self.bias     += total(update, /preserve_type)
    ; (*self.errors)[i] = total(update ne 0.0, /integer)

    if ((*self.errors)[i] eq 0L) then break
  endfor
end


;+
; Use previous training with `fit` method to predict targets for given data `x`.
;
; :Returns:
;   fltarr(n_samples)
;
; :Params:
;   x : in, required, type=fltarr(n_features, n_samples)
;     data to predict targets for
;   y : in, optional, type=fltarr(n_samples)
;     optional y-values; needed to get score
;
; :Keywords:
;   score : out, optional, type=float
;     set to a named variable to retrieve a score if `y` was specified
;-
function mg_perceptron::predict, x, y, score=score
  compile_opt strictarr

  y_predict = 2L * ((reform(*self.weights # x) + self.bias) ge 0.0) - 1L
  if (arg_present(score) && n_elements(y) gt 0) then begin
    score = total(y_predict eq y, /integer) / float(n_elements(y))
  endif
  return, y_predict
end


;= property access

pro mg_perceptron::getProperty, max_iterations=max_iterations, $
                                learning_rate=learning_rate, $
                                weights=weights, $
                                bias=bias, $
                                errors=errors, $
                                _ref_extra=e
  compile_opt strictarr

  if (arg_present(max_iterations)) then max_iterations = self.max_iterations
  if (arg_present(learning_rate)) then learning_rate = self.learning_rate
  if (arg_present(weights)) then weights = *self.weights
  if (arg_present(bias)) then bias = self.bias
  if (arg_present(errors)) then errors = *self.errors

  if (n_elements(e) gt 0L) then self->mg_estimator::getProperty, _extra=e
end


pro mg_perceptron::setProperty, max_iterations=max_iterations, $
                                learning_rate=learning_rate, $
                                _extra=e
  compile_opt strictarr

  if (n_elements(max_iterations) gt 0L) then self.max_iterations = max_iterations
  if (n_elements(learning_rate) gt 0L) then self.learning_rate = learning_rate
end


;= lifecycle methods

pro mg_perceptron::cleanup
  compile_opt strictarr

  ptr_free, self.weights, self.errors
  self->mg_estimator::cleanup
end


function mg_perceptron::init, max_iterations=max_iterations, $
                              learning_rate=learning_rate, $
                              _extra=e
  compile_opt strictarr

  if (~self->mg_estimator::init(_extra=e)) then return, 0

  self.type = 'binary classifier'

  self.weights = ptr_new(/allocate_heap)
  self.errors = ptr_new(/allocate_heap)

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
           bias: 0.0, $
           weights: ptr_new(), $
           errors: ptr_new() $
          }
end


; main-level example program

iris = mg_load_iris()

; the first 100 samples have only two target values (categories)
data = iris.data[*, 0:99]
target = 2L * iris.target[0:99] - 1L  ; change to -1 and 1

;seed = 0L
mg_train_test_split, data, target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test, $
                     test_size=0.15, $
                     seed=seed

p = mg_perceptron(max_iterations=10)
clock_id = tic('mg_perceptron')
p->fit, x_train, y_train
t = toc(clock_id)
y_results = p->predict(x_test, y_test, score=score)

print, format='(%"\n# Results\n")'

for s = 0L, n_elements(y_test) - 1L do begin
  if (y_results[s] eq y_test[s]) then begin
    print, s, iris.target_names[y_results[s] eq 1], $
           format='(%"%3d: results match, both: %s")'
  endif else begin
    print, s, iris.target_names[y_results[s] eq 1], $
              iris.target_names[y_test[s] eq 1], $
              format='(%"%3d: incorrect result: %s, test standard: %s")'
  endelse
endfor

print, t * 1000.0, format='(%"\nExecution time: %0.1f msec")'
print, score * 100.0, format='(%"Prediction score: %0.1f\%")'
fmt = strjoin(strarr(p.max_iterations) + '%d', ' ')
print, p.errors, format='(%"Errors per iteration: ' + fmt + '")'

print

print, format='(%"\n# Fit\n")'
print, p.bias, format='(%"bias: %0.2f")'
weights = p.weights
for w = 0L, n_elements(iris.feature_names) - 1L do begin
  print, iris.feature_names[w], weights[w], format='(%"%-20s: %0.2f")'
endfor

end

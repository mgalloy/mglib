; docformat = 'rst'

;+
; Least squares regressor.
;
; :Categories:
;   regressor
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
pro mg_ridgeregressor::fit, x, y
  compile_opt strictarr

  dims = size(x, /dimensions)
  type = size(x, /type)
  _x = make_array(dimension=[dims[0] + 1, dims[1]], type=type)
  _x[0, *] = fltarr(dims[1]) + fix(1.0, type=type)
  _x[1, 0] = x

  *self._weights = la_least_squares(transpose(_x) ## _x + sqrt(self.alpha) * identity(dims[0] + 1), $
                                   transpose(_x) ## y)
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
function mg_ridgeregressor::predict, x, y, score=score
  compile_opt strictarr

  dims = size(x, /dimensions)
  type = size(x, /type)
  _x = make_array(dimension=[dims[0] + 1, dims[1]], type=type)
  _x[0, *] = fltarr(dims[1]) + fix(1.0, type=type)
  _x[1, 0] = x

  y_predict = reform(*self._weights # _x)

  if (arg_present(score) && n_elements(y) gt 0) then begin
    score = self->_r2_score(y, y_predict)
  endif

  return, y_predict
end


;= overload methods

function mg_ridgeregressor::_overloadHelp, varname
  compile_opt strictarr

  _type = 'RR'
  _specs = string(self.alpha, format='(%"<alpha: %0.2f>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_ridgeregressor::getProperty, intercept=intercept, $
                                    coefficients=coefficients, $
                                    alpha=alpha, $
                                    fit_parameters=fit_parameters, $
                                    _ref_extra=e
  compile_opt strictarr

  if (arg_present(intercept)) then intercept = (*self._weights)[0]
  if (arg_present(coefficients)) then coefficients = (*self._weights)[1:*]
  if (arg_present(alpha)) then alpha = self.alpha
  if (arg_present(fit_parameters)) then fit_parameters = *self.weights

  if (n_elements(e) gt 0L) then self->mg_regressor::getProperty, _extra=e
end


pro mg_ridgeregressor::setProperty, alpha=alpha, fit_parameters=fit_parameters, _extra=e
  compile_opt strictarr

  if (n_elements(alpha) gt 0L) then self.alpha = alpha
  if (n_elements(fit_parameters) gt 0L) then *self._weights = fit_parameters

  if (n_elements(e) gt 0L) then self->mg_regressor::setProperty, _extra=e
end


;= lifecycle methods

pro mg_ridgeregressor::cleanup
  compile_opt strictarr

  ptr_free, self._weights
  self->mg_regressor::cleanup
end


function mg_ridgeregressor::init, alpha=alpha, _extra=e
  compile_opt strictarr

  if (~self->mg_regressor::init()) then return, 0

  self._weights = ptr_new(/allocate_heap)

  self->setProperty, alpha=mg_default(alpha, 1.0), _extra=e

  return, 1
end


pro mg_ridgeregressor__define
  compile_opt strictarr

  !null = {mg_ridgeregressor, inherits mg_regressor, $
           alpha: 0.0, $
           _weights: ptr_new() $
          }
end


; main-level example program

wave = mg_learn_dataset('wave', n_samples=100)
mg_train_test_split, wave.data, wave.target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test

lsr = mg_ridgeregressor(alpha=0.1)
lsr->fit, x_train, y_train
y_predict = lsr->predict(x_test, y_test, score=r2_test)
y_predict = lsr->predict(x_train, y_train, score=r2_train)

print, r2_train, format='(%"train r^2: %f")'
print, r2_test, format='(%"test r^2: %f")'
print, lsr.intercept, format='(%"intercept:    %f")'
print, strjoin(strtrim(lsr.coefficients, 2), ', '), $
       format='(%"coefficients: %s")'

plot, wave.data, wave.target, psym=mg_usersym(/circle)
r = !x.crange
n = 100
x = (r[1] - r[0]) * findgen(100) / (n - 1) + r[0]
y = lsr.intercept + (lsr.coefficients)[0] * x
oplot, x, y

obj_destroy, lsr


boston = mg_learn_dataset('boston')

mg_train_test_split, boston.data, boston.target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test

lsr = mg_ridgeregressor()
lsr->fit, x_train, y_train
y_predict = lsr->predict(x_test, y_test, score=r2_test)
y_predict = lsr->predict(x_train, y_train, score=r2_train)

print, r2_train, format='(%"train r^2: %f")'
print, r2_test, format='(%"test r^2: %f")'
print, lsr.intercept, format='(%"intercept:    %f")'
print, strjoin(strtrim(lsr.coefficients, 2), ', '), $
       format='(%"coefficients: %s")'

obj_destroy, lsr

end

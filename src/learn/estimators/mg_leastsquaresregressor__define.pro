; docformat = 'rst'

;+
; Least squares regressor.
;
; :Categories:
;   regressor
;
; :Properties:
;   fit_intercept : type=boolean
;     whether to calculate the intercept for this model. If set to false, no
;     intercept will be used in calculations (e.g. data is expected to be
;     already centered).
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
pro mg_leastsquaresregressor::fit, x, y
  compile_opt strictarr

  dims = size(x, /dimensions)
  type = size(x, /type)

  if (self.fit_intercept) then begin
    _x = make_array(dimension=[dims[0] + 1, dims[1]], type=type)
    _x[0, *] = fltarr(dims[1]) + fix(1.0, type=type)
    _x[1, 0] = x
    *self.weights = la_least_squares(_x, y)
  endif else begin
    *self.weights = la_least_squares(x, y)
  endelse
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
function mg_leastsquaresregressor::predict, x, y, score=score
  compile_opt strictarr

  dims = size(x, /dimensions)
  type = size(x, /type)

  if (self.fit_intercept) then
    _x = make_array(dimension=[dims[0] + 1, dims[1]], type=type)
    _x[0, *] = fltarr(dims[1]) + fix(1.0, type=type)
    _x[1, 0] = x
    y_predict = reform(_x ## *self.weights)
  endif else begin
    y_predict = reform(x ## *self.weights)
  endelse

  if (arg_present(score) && n_elements(y) gt 0) then begin
    score = self->_r2_score(y, y_predict)
  endif

  return, y_predict
end


;= property access

pro mg_leastsquaresregressor::getProperty, fit_intecept=fit_intercept, $
                                           intercept=intercept, $
                                           coefficients=coefficients, $
                                           _ref_extra=e
  compile_opt strictarr

  if (arg_present(fit_intercept)) then fit_intercept = self.fit_intercept
  if (arg_present(intercept)) then begin
    intercept = self.fit_intercept ? (*self.weights)[0] : 0.0
  endif
  if (arg_present(coefficients)) then coefficients = (*self.weights)[1:*]
  if (n_elements(e) gt 0L) then self->mg_regressor::getProperty, _extra=e
end


pro mg_leastsquaresregressor::setProperty, fit_intercept=fit_intercept, $
                                           _extra=e
  compile_opt strictarr

  if (n_elements(fit_intercept) gt 0L) then self.fit_intercept = keyword_set(fit_intercept)
  if (n_elements(e) gt 0L) then self->mg_regressor::setProperty, _extra=e
end


;= lifecycle methods

pro mg_leastsquaresregressor::cleanup
  compile_opt strictarr

  ptr_free, self.weights
  self->mg_regressor::cleanup
end


function mg_leastsquaresregressor::init, _extra=e
  compile_opt strictarr

  if (~self->mg_regressor::init(_extra=e)) then return, 0

  self.fit_intercept = 1B
  self.weights = ptr_new(/allocate_heap)

  self->setProperty, _extra=e

  return, 1
end


pro mg_leastsquaresregressor__define
  compile_opt strictarr

  !null = {mg_leastsquaresregressor, inherits mg_regressor, $
           weights: ptr_new(), $
           fit_intercept: 0B, $
          }
end


; main-level example program

wave = mg_learn_dataset('wave', n_samples=100)
mg_train_test_split, wave.data, wave.target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test

lsr = mg_leastsquaresregressor()
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

lsr = mg_leastsquaresregressor()
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

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
pro mg_leastsquaresregressor::fit, x, y
  compile_opt strictarr

  dims = size(x, /dimensions)
  type = size(x, /type)
  _x = make_array(dimension=[dims[0] + 1, dims[1]], type=type)
  _x[0, *] = fltarr(dims[1]) + fix(1.0, type=type)
  _x[1, 0] = x

  *self.weights = la_least_squares(_x, y)
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
function mg_leastsquaresregressor::predict, x, y, score=score
  compile_opt strictarr

  dims = size(x, /dimensions)
  type = size(x, /type)
  _x = make_array(dimension=[dims[0] + 1, dims[1]], type=type)
  _x[1, 0] = x

  y_predict = reform(*self.weights # _x)

  if (arg_present(score) && n_elements(y) gt 0) then begin
    score = self->_r2_score(y, y_predict)
  endif

  return, y_predict
end


;= property access

pro mg_leastsquaresregressor::getProperty, weights=weights, _ref_extra=e
  compile_opt strictarr

  if (arg_present(weights)) then weights = *self.weights
  if (n_elements(e) gt 0L) then self->mg_regressor::getProperty, _extra=e
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

  self.weights = ptr_new(/allocate_heap)

  return, 1
end


pro mg_leastsquaresregressor__define
  compile_opt strictarr

  !null = {mg_leastsquaresregressor, inherits mg_regressor, $
           weights: ptr_new() $
          }
end


; main-level example program

wave = mg_learn_dataset('wave', n_samples=100)
mg_train_test_split, wave.data, wave.target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test

lsr = mg_leastsquaresregressor()
lsr->fit, x_train, y_train
y_predict = lsr->predict(x_test, y_test, score=r2)
print, r2, format='(%"r^2: %f")'
;obj_destroy, lsr

end

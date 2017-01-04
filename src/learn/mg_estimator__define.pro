; docformat = 'rst'

; API

;+
; Use training set of data `x` and targets `y` to train the model.
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     data to learn on
;   y : in, required, type=fltarr(n_samples)
;     results for `x` data
;-
pro mg_estimator::fit, x, y
  compile_opt strictarr
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
;-
function mg_estimator::predict, x
  compile_opt strictarr
end


;+
; Predict targets for `x` values and compare to `y`, returning percentage
; correct.
;-
function mg_estimator::score, x, y
  compile_opt strictarr

  return, 0.0
end


;= property access

;= lifecycle methods

;+
; Get property values.
;-
pro mg_estimator::getProperty, type=type
  compile_opt strictarr

  if (arg_present(type)) then type = self.type
end


pro mg_estimator::setProperty
  compile_opt strictarr

end


;+
; Free resources
;-
pro mg_estimator::cleanup
  compile_opt strictarr

end

;+
; Create estimator object.
;
; :Returns:
;   1 for success, 0 for failure
;-
function mg_estimator::init
  compile_opt strictarr

  return, 1
end


;+
; Define estimator class.
;-
pro mg_estimator__define
  compile_opt strictarr

  !null = {mg_estimator, inherits IDL_Object, $
           type:''}
end

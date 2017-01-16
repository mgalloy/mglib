; docformat = 'rst'

;= API

;+
; Use training set of data `x` and targets `y` to train the model.
;
; :Abstract:
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     data to learn on
;   y : in, required, type=fltarr(n_samples)
;     results for `x` data
;-
pro mg_estimator::fit, x, y
  compile_opt strictarr

  ; not implemented
end


;+
; Use previous training with `fit` method to predict targets for given data `x`.
;
; :Abstract:
;
; :Returns:
;   fltarr(n_samples)
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     data to predict targets for
;   y : in, optional, type=fltarr(n_samples)
;     optional y-values; needed to get score
;
; :Keywords:
;   score : out, optional, type=float
;     set to a named variable to retrieve a score if `y` was specified
;-
function mg_estimator::predict, x, y, score=score
  compile_opt strictarr

  ; not implemented
  return, !null
end


;+
; Predict targets for `x` values and compare to `y`, returning percentage
; correct.
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     data to score on
;   y : in, required, type=fltarr(n_samples)
;     results for `x` data, which will be compared to actual prediction for `x`
;-
function mg_estimator::score, x, y
  compile_opt strictarr

  result = self->predict(x, y, score=score)
  return, score
end


;= overload methods

function mg_estimator::_overloadHelp, varname
  compile_opt strictarr

  _type = self.type
  _specs = string(format='(%"<>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

;+
; Get property values.
;-
pro mg_estimator::getProperty, type=type
  compile_opt strictarr

  if (arg_present(type)) then type = self.type
end


;+
; Set property values.
;-
pro mg_estimator::setProperty, _extra=e
  compile_opt strictarr

end


;= lifecycle methods

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
function mg_estimator::init, _extra=e
  compile_opt strictarr

  self->setProperty, _extra=e

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

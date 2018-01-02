; docformat = 'rst'

;= API

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
function mg_predictor::predict, x, y, score=score
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
function mg_predictor::score, x, y
  compile_opt strictarr

  result = self->predict(x, y, score=score)
  return, score
end


;= overload methods

function mg_predictor::_overloadHelp, varname
  compile_opt strictarr

  _type = self.type eq '' ? 'PRED' : self.type
  _specs = '<None>'
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

;= lifecycle

;+
; Free resources
;-
pro mg_predictor::cleanup
  compile_opt strictarr

  self->mg_estimator::cleanup
end


;+
; Create transformer object.
;
; :Returns:
;   1 for success, 0 for failure
;-
function mg_predictor::init, _extra=e
  compile_opt strictarr

  if (self->mg_estimator::init() eq 0L) then return, 0

  self->setProperty, _extra=e

  return, 1
end


;+
; Define the transfomer class.
;-
pro mg_predictor__define
  compile_opt strictarr

  !null = {mg_predictor, inherits mg_estimator}
end

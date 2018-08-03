; docformat = 'rst'

;+
; Logistic regression classifier
;
; [1]: http://scikit-learn.org/stable/modules/linear_model.html#logistic-regression
;
; :Categories:
;   classifier
;
; :Properties:
;   c : type=float
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
pro mg_logisticregression::fit, x, y
  compile_opt strictarr

  ; TODO: implement
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
function mg_logisticregression::predict, x, y, score=score
  compile_opt strictarr

  ; TODO: implement
end


;= overload methods

function mg_logisticregression::_overloadHelp, varname
  compile_opt strictarr

  _type = 'LOGREG'
  _specs = string(self.c, $
                  format='(%"<C: %0.2f>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_logisticregression::getProperty, c=c, $
                                        fit_parameters=fit_parameters, $
                                        _ref_extra=e
  compile_opt strictarr

  if (arg_present(c)) then c = self.c
  if (arg_present(fit_parameters)) then begin
    fit_parameters = {c: self.c}
  endif

  if (n_elements(e) gt 0L) then self->mg_classifier::getProperty, _extra=e
end


pro mg_logisticregression::setProperty, c=c, $
                                        fit_parameters=fit_parameters, $
                                        _extra=e
  compile_opt strictarr

  if (n_elements(c) gt 0L) then self.c = c
  if (n_elements(fit_parameters) gt 0L) then begin
    self.c = fit_parameters.c
  endif

  if (n_elements(e) gt 0L) then self->mg_classifier::setProperty, _extra=e
end


;= lifecycle

;+
; Free resources.
;-
pro mg_logisticregression::cleanup
  compile_opt strictarr

  self->mg_classifier::cleanup
end


;+
; Instantiate logistic regression classifier.
;
; :Returns:
;   1 if success, 0 for failure
;-
function mg_logisticregression::init, c=c, _extra=e
  compile_opt strictarr

  if (~self->mg_classifier::init(_extra=e)) then return, 0

  self.type eq 'classifier'

  self->setProperty, c=mg_default(c, 1.0)

  return, 1
end


;+
; Define logistic regression class.
;-
pro mg_logisticregression__define
  compile_opt strictarr

  !null = {mg_logisticregression, inherits mg_classifier, $
           c: 0.0}
end

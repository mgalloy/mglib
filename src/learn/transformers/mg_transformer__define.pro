; docformat = 'rst'

;+
; Transformers are estimators that prepare data for an predictor.
;
; Transformers have two main methods, `fit` (from being an estimator) and
; `transform`, along with the convenience method `fit_transform` that simply
; calls them both in sequence.
;
; A typical workflow is to fit and transform the training data, then transform
; test data::
;
;   x_train_transformed = trans->fit_transform(x_train)
;   x_test_transformed = trans->transform(x_test)
;-


;= API

;+
; Use training data `x` to determine the transformation.
;
; :Abstract:
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     data to learn on
;-
pro mg_transformer::fit, x, y, feature_names=feature_names
  compile_opt strictarr

  self->mg_estimator::fit, x, y

  if (n_elements(feature_names) eq 0L) then begin
    if (n_elements(*self.feature_names) eq 0L) then begin
      dims = size(x, /dimensions)
      self->setProperty, feature_names='x' + strtrim(lindgen(dims[0]), 2)
    endif
  endif else self->setProperty, feature_names=feature_names

  ; not implemented
end


;+
; Apply the learned transform to `x`.
;
; :Abstract:
;
; :Returns:
;   `fltarr(n_new_features, n_samples)`
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     data to transform
;-
function mg_transformer::transform, x
  compile_opt strictarr

  ; not implemented
end


;+
; Convenience method that performs a `fit` and then a `transform`.
;
; :Returns:
;   `fltarr(n_new_features, n_samples)`
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     data to fit and transform
;-
function mg_transformer::fit_transform, x, y, _extra=e
  compile_opt strictarr

  self->fit, x, y, _extra=e
  return, self->transform(x)
end


;= overload methods

function mg_transformer::_overloadHelp, varname
  compile_opt strictarr

  _type = self.type eq '' ? 'TRANS' : self.type
  _specs = '<None>'
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

;+
; Get property values.
;-
pro mg_transformer::getProperty, feature_names=feature_names, $
                                 fit_parameters=fit_parameters, $
                                 _ref_extra=e
  compile_opt strictarr

  if (arg_present(feature_names)) then feature_names = *self.feature_names

  ; FIT_PARAMETERS is here for the interface, but nothing to give in the general
  ; case

  if (n_elements(e) gt 0L) then self->mg_estimator::getProperty, _extra=e
end


;+
; Set property values.
;-
pro mg_transformer::setProperty, feature_names=feature_names, $
                                 fit_parameters=fit_parameters, $
                                 _extra=e
  compile_opt strictarr

  if (n_elements(feature_names) gt 0L) then *self.feature_names = feature_names

  ; FIT_PARAMETERS is here for the interface, but nothing to give in the general
  ; case

  if (n_elements(e) gt 0L) then self->mg_estimator::setProperty, _extra=e
end


;= lifecycle methods

;+
; Free resources
;-
pro mg_transformer::cleanup
  compile_opt strictarr

  self->mg_estimator::cleanup

  ptr_free, self.feature_names
end


;+
; Create transformer object.
;
; :Returns:
;   1 for success, 0 for failure
;-
function mg_transformer::init, _extra=e
  compile_opt strictarr

  if (self->mg_estimator::init() eq 0L) then return, 0

  self.feature_names = ptr_new(/allocate_heap)
  self->setProperty, _extra=e

  return, 1
end


;+
; Define the transfomer class.
;-
pro mg_transformer__define
  compile_opt strictarr

  !null = {mg_transformer, inherits mg_estimator, $
           feature_names: ptr_new() $
          }
end

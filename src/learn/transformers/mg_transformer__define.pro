; docformat = 'rst'

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
pro mg_estimator::fit, x
  compile_opt strictarr

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
function mg_transformer::fit_transform, x
  compile_opt strictarr

  self->fit, x
  return, self->transform(x)
end


;= property access

;+
; Get property values.
;-
pro mg_transformer::getProperty, _extra=e
  compile_opt strictarr

end


;+
; Set property values.
;-
pro mg_transformer::setProperty, _extra=e
  compile_opt strictarr

end


;= lifecycle methods

;+
; Free resources
;-
pro mg_transformer::cleanup
  compile_opt strictarr

end

;+
; Create transformer object.
;
; :Returns:
;   1 for success, 0 for failure
;-
function mg_transformer::init, _extra=e
  compile_opt strictarr

  self->setProperty, _extra=e

  return, 1
end


;+
; Define the transfomer class.
;-
pro mg_transformer__define
  compile_opt strictarr

  !null = {mg_transformer, inherits IDL_Object}
end

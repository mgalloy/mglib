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


;= overload methods

function mg_estimator::_overloadHelp, varname
  compile_opt strictarr

  _type = self.type eq '' ? 'ESTIM' : self.type
  _specs = '<None>'
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

;+
; Get property values.
;-
pro mg_estimator::getProperty, name=name, type=type, $
                               fit_parameters=fit_parameters
  compile_opt strictarr

  if (arg_present(name)) then name = self.name
  if (arg_present(type)) then type = self.type

  ; FIT_PARAMETERS is here for the interface, but nothing to give in the general
  ; case
end


;+
; Set property values.
;-
pro mg_estimator::setProperty, name=name, type=type, $
                               fit_parameters=fit_parameters, $
                               _extra=e
  compile_opt strictarr

  if (n_elements(name) gt 0L) then self.name = name
  if (n_elements(type) gt 0L) then self.type = type

  ; FIT_PARAMETERS is here for the interface, but nothing to give in the general
  ; case
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

  self.name = strlowcase(obj_class(self))

  self->setProperty, _extra=e

  return, 1
end


;+
; Define estimator class.
;-
pro mg_estimator__define
  compile_opt strictarr

  !null = {mg_estimator, inherits IDL_Object, $
           type:'', $
           name: ''}
end

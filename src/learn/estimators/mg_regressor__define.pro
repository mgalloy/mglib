; docformat = 'rst'


;= helper methods

function mg_regressor::_r2_score, y, y_predict
  compile_opt strictarr

  ss_tot = total((y - mean(y))^2, /preserve_type)
  ss_res = total((y - y_predict)^2, /preserve_type)
  r2 = 1.0 - ss_res / ss_tot

  return, r2
end

;= property access

pro mg_regressor::getProperty, _ref_extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->mg_estimator::getProperty, _extra=e
end


pro mg_regressor::setProperty, _extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->mg_estimator::setProperty, _extra=e
end


;= overload methods

function mg_regressor::_overloadHelp, varname
  compile_opt strictarr

  _type = self.type
  _specs = '<>'
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= lifecycle methods

pro mg_regressor::cleanup
  compile_opt strictarr

  self->mg_estimator::cleanup
end


function mg_regressor::init, _extra=e
  compile_opt strictarr

  if (~self->mg_estimator::init(_extra=e)) then return, 0

  self.type = 'regressor'

  return, 1
end


pro mg_regressor__define
  compile_opt strictarr

  !null = {mg_regressor, inherits mg_estimator}
end

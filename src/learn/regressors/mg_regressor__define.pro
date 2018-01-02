; docformat = 'rst'


;= helper methods

function mg_regressor::_r2_score, y, y_predict
  compile_opt strictarr

  return, mg_r2_score(y, y_predict)
end

;= property access

pro mg_regressor::getProperty, _ref_extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->mg_predictor::getProperty, _extra=e
end


pro mg_regressor::setProperty, _extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->mg_predictor::setProperty, _extra=e
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

  self->mg_predictor::cleanup
end


function mg_regressor::init, _extra=e
  compile_opt strictarr

  if (~self->mg_predictor::init()) then return, 0

  self.type = 'regressor'

  self->setProperty, _extra=e

  return, 1
end


pro mg_regressor__define
  compile_opt strictarr

  !null = {mg_regressor, inherits mg_predictor}
end

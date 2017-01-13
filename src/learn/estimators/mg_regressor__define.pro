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

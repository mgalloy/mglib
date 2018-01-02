; docformat = 'rst'


;= helper methods


;= property access

pro mg_classifier::getProperty, _ref_extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->mg_predictor::getProperty, _extra=e
end


pro mg_classifier::setProperty, _extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->mg_predictor::setProperty, _extra=e
end


;= overload methods

function mg_classifier::_overloadHelp, varname
  compile_opt strictarr

  _type = self.type
  _specs = '<>'
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= lifecycle methods

pro mg_classifier::cleanup
  compile_opt strictarr

  self->mg_predictor::cleanup
end


function mg_classifier::init, _extra=e
  compile_opt strictarr

  if (~self->mg_predictor::init(_extra=e)) then return, 0

  self.type = 'classifier'

  return, 1
end


pro mg_classifier__define
  compile_opt strictarr

  !null = {mg_classifier, inherits mg_predictor}
end

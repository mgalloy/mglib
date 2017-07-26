; docformat = 'rst'


;= API

pro mg_functiontransformer::fit, x, y, _extra=e
  compile_opt strictarr

  self->mg_transformer::fit, x, y, _extra=e
end


function mg_functiontransformer::transform, x
  compile_opt strictarr

  return, call_function(self.function_name, x)
end


;= overload methods

function mg_functiontransformer::_overloadHelp, varname
  compile_opt strictarr

  _type = 'FUNCTRANS'
  _specs = string(self.function_name, format='(%"<function: %s>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_functiontransformer::getProperty, function_name=function_name, $
                                         fit_parameters=fit_parameters, $
                                         _ref_extra=e
  compile_opt strictarr

  if (arg_present(function_name)) then function_name = self.function_name
  if (arg_present(fit_parameters)) then fit_parameters = 1

  if (n_elements(e) gt 0L) then self->mg_transformer::getProperty, _extra=e
end


pro mg_functiontransformer::setProperty, function_name=function_name, $
                                         fit_parameters=fit_parameters, $
                                         _extra=e
  compile_opt strictarr

  if (n_elements(function_name) gt 0L) then self.function_name = function_name
  ; don't need to do anything for FIT_PARAMETERS, it's just here for consistency
  if (n_elements(e) gt 0L) then self->mg_transformer::setProperty, _extra=e
end


;= lifecycle methods

pro mg_functiontransformer::cleanup
  compile_opt strictarr

  self->mg_transformer::cleanup
end


function mg_functiontransformer::init, _extra=e
  compile_opt strictarr

  if (~self->mg_transformer::init(_extra=e)) then return, 0

  return, 1
end


pro mg_functiontransformer__define
  compile_opt strictarr

  !null = {mg_functiontransformer, inherits mg_transformer, $
           function_name: ''}
end


; main-level program

x = findgen(2, 1000)
sintrans = mg_functiontransformer(function_name='sin', feature_names=['x', 'y'])
sin_x = sintrans->fit_transform(x)
window, xsize=800, ysize=400, title='sin transform', /free
!p.multi = [0, 2, 1]
plot, x[0, *], x[1, *], psym=3
plot, sin_x[0, *], sin_x[1, *], psym=3
!p.multi = 0
obj_destroy, sintrans

x = findgen(2, 1000)
log1 = mg_functiontransformer(function_name=lambda(x: alog(x + 1)), feature_names=['x', 'y'])
log1_x = log1->fit_transform(x)
window, xsize=800, ysize=400, title='alog(x + 1) transform', /free
!p.multi = [0, 2, 1]
plot, x[0, *], x[1, *], psym=3
plot, log1_x[0, *], log1_x[1, *], psym=3
!p.multi = 0

obj_destroy, log1

end

; docformat = 'rst'

;= API

pro mg_learn_pipeline::fit, x, y
  compile_opt strictarr

  new_x = x
  for s = 0L, n_elements(*self.steps) - 1L do begin
    step = (*self.steps)[s]
    new_x = step->fit_transform(new_x, y)
  endfor
end


function mg_learn_pipeline::predict, x, y, score=score
  compile_opt strictarr

  new_x = x
  for s = 0L, n_elements(*self.steps) - 1L do begin
    step = (*self.steps)[s]
    new_x = step->predict(new_x, y, score=arg_present(score) ? score : 0)
  endfor

  return, new_x
end


;= overload methods

function mg_learn_pipeline::_overloadHelp, varname
  compile_opt strictarr

  _type = 'PIPELINE'
  _specs = string(n_elements(*self.steps), format='(%"<%d steps>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_learn_pipeline::getProperty
  compile_opt strictarr

end


pro mg_learn_pipeline::setProperty
  compile_opt strictarr

end


;= lifecycle

pro mg_learn_pipeline::cleanup
  compile_opt strictarr

  obj_destroy, *self.steps
  ptr_new, self.steps
end


function mg_learn_pipeline::init, steps
  compile_opt strictarr

  self.steps = ptr_new(steps)

  return, 1
end


pro mg_learn_pipeline__define
  compile_opt strictarr

  !null = {mg_learn_pipeline, inherits IDL_Object, $
           steps: ptr_new()}
end

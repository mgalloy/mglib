; docformat = 'rst'

;= API

pro mg_learn_pipeline::fit, x, y, feature_names=feature_names, _extra=e
  compile_opt strictarr

  new_x = x
  _feature_names = mg_default(feature_names, ((*self.steps)[0]).feature_names)
  for s = 0L, n_elements(*self.steps) - 2L do begin
    step = (*self.steps)[s]
    help, step
    new_x = step->fit_transform(new_x, y, feature_names=_feature_names)
  endfor
  last_step = (*self.steps)[-1]
  new_x = last_step->fit(new_x, y, feature_names=_feature_names)
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

pro mg_learn_pipeline::getProperty, steps=steps, $
                                    n_steps=n_steps, $
                                    feature_names=feature_names
  compile_opt strictarr

  if (arg_present(steps)) then steps = *self.steps
  if (arg_present(n_steps)) then n_steps = n_elements(*self.steps)
  if (arg_present(feature_names)) then begin
    last_step = (*self.steps)[-1]
    feature_names = last_step.feature_names
  endif
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


; main-level program

data = [{rooms: 4, neighborhood: 'Queen Anne'}, $
        {rooms: 3, neighborhood: 'Fremont'}, $
        {rooms: 3, neighborhood: 'Wallingford'}, $
        {rooms: 2, neighborhood: 'Fremont'}]
prices = [850000, 700000, 650000, 600000]

pipeline = mg_learn_pipeline([mg_structvectorizer(), $
                              mg_polynomialfeatures(degree=2), $
                              mg_leastsquaresregressor()])
pipeline->fit, data, prices
prices_predict = pipeline->predict(data, prices, score=score)

obj_destroy, pipeline

end

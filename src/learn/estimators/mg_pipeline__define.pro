; docformat = 'rst'

;= API

pro mg_pipeline::fit, x, y, feature_names=feature_names, _extra=e
  compile_opt strictarr

  new_x = x
  _feature_names = mg_default(feature_names, ((*self.steps)[0]).feature_names)
  for s = 0L, n_elements(*self.steps) - 2L do begin
    new_x = ((*self.steps)[s])->fit_transform(new_x, y, $
                                              feature_names=_feature_names)
    _feature_names = ((*self.steps)[s]).feature_names
  endfor
  ((*self.steps)[-1])->fit, new_x, y
end


function mg_pipeline::predict, x, y, score=score
  compile_opt strictarr

  new_x = x
  for s = 0L, n_elements(*self.steps) - 2L do begin
    new_x = ((*self.steps)[s])->transform(new_x)
  endfor

  return, ((*self.steps)[-1])->predict(new_x, $
                                       y, $
                                       score=arg_present(score) ? score : 0)

end


;= overload methods

function mg_pipeline::_overloadHelp, varname
  compile_opt strictarr

  _type = 'PIPELINE'
  _specs = string(n_elements(*self.steps), format='(%"<%d steps>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_pipeline::getProperty, steps=steps, $
                              n_steps=n_steps, $
                              feature_names=feature_names, $
                              fit_parameters=fit_parameters, $
                              _ref_extra=e
  compile_opt strictarr

  if (arg_present(steps)) then steps = *self.steps
  if (arg_present(n_steps)) then n_steps = n_elements(*self.steps)
  if (arg_present(feature_names)) then begin
    last_step = (*self.steps)[-1]
    feature_names = last_step.feature_names
  endif

  if (arg_present(fit_parameters)) then begin
    fit_parameters = {}
    for s = 0L, n_elements(*self.steps) - 1L do begin
      fit_parameters = create_struct(fit_parameters, $
                                     string(s, format='(%"_%d")'), $
                                     ((*self.steps)[s]).fit_parameters)
    endfor
  endif

  if (n_elements(e) gt 0L) then self->mg_estimator::getProperty, _extra=e
end


pro mg_pipeline::setProperty, fit_parameters=fit_parameters, _extra=e
  compile_opt strictarr

  if (n_elements(fit_parameters) gt 0L) then begin
    for s = 0L, n_tags(fit_parameters) - 1L do begin
      ((*self.steps)[s]).fit_parameters = fit_parameters.(s)
    endif
  endif

  self->mg_estimator::setProperty, _extra=e
end


;= lifecycle

pro mg_pipeline::cleanup
  compile_opt strictarr

  obj_destroy, *self.steps
  ptr_free, self.steps
end


function mg_pipeline::init, steps, _extra=e
  compile_opt strictarr

  if (~self->mg_estimator::init(_extra=e)) then return, 0

  self.type = 'pipeline'
  self.steps = ptr_new(steps)

  return, 1
end


pro mg_pipeline__define
  compile_opt strictarr

  !null = {mg_pipeline, inherits mg_estimator, $
           steps: ptr_new()}
end


; main-level program

data = [{rooms: 4, neighborhood: 'Queen Anne'}, $
        {rooms: 3, neighborhood: 'Fremont'}, $
        {rooms: 3, neighborhood: 'Wallingford'}, $
        {rooms: 2, neighborhood: 'Fremont'}]
prices = [850000, 700000, 650000, 600000]

pipeline = mg_pipeline([mg_structvectorizer(), $
                        mg_polynomialfeatures(degree=2), $
                        mg_leastsquaresregressor()])
pipeline->fit, data, prices, feature_names=tag_names(data)
prices_predict = pipeline->predict(data, prices, score=score)
print, score, format='(%"Score for Boston data: %0.2f")'
obj_destroy, pipeline

boston = mg_learn_dataset('boston')
mg_train_test_split, boston.data, boston.target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test

pipeline1 = mg_pipeline([mg_minmaxscaler(), mg_ridgeregressor()])
pipeline1->fit, x_train, y_train, feature_names=boston.feature_names
y_test_predict1 = pipeline1->predict(x_test, y_test, score=score_scaled)
print, score_scaled, format='(%"Score for scaled data: %0.2f")'
obj_destroy, pipeline1

pipeline2 = mg_pipeline([mg_minmaxscaler(), $
                         mg_polynomialfeatures(degree=2), $
                         mg_ridgeregressor()])
pipeline2->fit, x_train, y_train, feature_names=boston.feature_names
y_test_predict2 = pipeline2->predict(x_test, y_test, score=score_poly)
print, score_poly, format='(%"Score for scaled data with polynomial features: %0.2f")'
obj_destroy, pipeline2

end

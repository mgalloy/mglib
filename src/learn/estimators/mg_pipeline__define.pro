; docformat = 'rst'


;+
; Pipeline estimator, a collection of transformers and an estimator applied in
; order.
;-


;= API

;+
; Use training set of data `x` and targets `y` to train the model.
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     data to learn on
;   y : in, required, type=lonarr(n_samples)
;     unused
;
; :Keywords:
;   seed : in, out, optional, type=integer
;     random number generator seed
;-
pro mg_kmeans::fit, x, y, _extra=e
  compile_opt strictarr

  new_x = x

  for s = 0L, n_elements(*self.steps) - 2L do begin
    new_x = (*self.steps)[s]->fit_transform(new_x, y)
  endfor

  ((*self.steps)[-1])->fit, new_x, y
end


;+
; Use previous training with `fit` method to predict targets for given data `x`.
;
; :Returns:
;   `lonarr(n_samples)`
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     data to predict targets for
;   y : in, optional, type=lonarr(n_samples)
;     optional y-values; needed to get score; values must be -1 or 1
;
; :Keywords:
;   score : out, optional, type=float
;     set to a named variable to retrieve a score if `y` was specified
;-
function mg_kmeans::predict, x, y, score=score
  compile_opt strictarr

  new_x = x

  for s = 0L, n_elements(*self.steps) - 2L do begin
    new_x = (*self.steps)[s]->transform(new_x, y)
  endfor

  return, ((*self.steps)[-1])->predict(new_x, y, score=score)
end


;= overload methods

function mg_pipeline::_overloadHelp, varname
  compile_opt strictarr

  _type = 'Pipeline'
  _specs = string(n_elements(*self.steps), format='(%"<%d steps>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_pipeline::getProperty, steps=steps
  compile_opt strictarr

  if (arg_present(steps)) then steps = *self.steps

  if (n_elements(e) gt 0L) then self->mg_estimator::getProperty, _extra=e
end


;= lifecycle methods

pro mg_pipeline::cleanup
  compile_opt strictarr

  obj_destroy, self.steps
  ptr_free, self.steps
  self->mg_estimator::cleanup
end


;+
; Create pipeline object.
;
; :Returns:
;   1 for success, 0 for failure
;-
function mg_pipeline::init, steps, _extra=e
  compile_opt strictarr

  if (~self->mg_estimator::init(_extra=e)) then return, 0

  self.type = 'pipeline'

  self.steps = ptr_new(steps)

  return, 1
end


;+
; Define pipeline class.
;-
function mg_pipeline__define
  compile_opt strictarr

  !null = {mg_pipeline, inherits mg_estimator, $
           steps: ptr_new()}
end

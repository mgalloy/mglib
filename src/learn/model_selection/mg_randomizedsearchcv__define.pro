; docformat = 'rst'

;= API

;+
; Use training set of data `x` and targets `y` to train the model.
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     data to learn on
;   y : in, required, type=lonarr(n_samples)
;     results for `x` data
;
; :Keywords:
;   seed : in, out, optional, type=integer
;     random number generator seed
;-
pro mg_randomizedsearchcv::fit, x, y, seed=seed
  compile_opt strictarr

  first_try = 1B
  foreach pset, self, key do begin
    ; set parameters on self.predictor to pset
    self.predictor->setProperty, _extra=pset

    ; fit
    self.predictor->fit, x, y

    ; score
    scores = mg_cross_val_score(self.predictor, x, y, $
                                cross_validation=self.cross_validation)
    score = mean(scores)

    ; save score and parameters if best score so far
    if (first_try || score gt self.best_score) then begin
      self.best_score = score
      *self.best_parameters = pset
      *self.best_fit_parameters = self.predictor.fit_parameters
    endif
    first_try = 0B
  endforeach
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
;     optional y-values; needed to get score
;
; :Keywords:
;   score : out, optional, type=float
;     set to a named variable to retrieve a score if `y` was specified
;-
function mg_randomizedsearchcv::predict, x, y, score=score
  compile_opt strictarr

  self.predictor->setProperty, _extra=*self.best_parameters
  self.predictor.fit_parameters = *self.best_fit_parameters
  return, self.predictor->predict(x, y, score=score)
end


;= property access

pro mg_randomizedsearchcv::getProperty, parameter_distributions=parameter_distributions, $
                                        cross_validation=cross_validation, $
                                        best_score=best_score, $
                                        best_parameters=best_parameters, $
                                        _ref_extra=e
  compile_opt strictarr

  if (arg_present(parameter_distributions)) then parameter_distributions = *self.parameter_distributions
  if (arg_present(cross_validation)) then cross_validation = self.cross_validation
  if (arg_present(best_score)) then best_score = self.best_score
  if (arg_present(best_parameters)) then best_parameters = *self.best_parameters

  if (n_elements(e) gt 0L) then self->mg_predictor::getProperty, _extra=e
end


;= overload methods

function mg_randomizedsearchcv::_overloadForeach, value, key
  compile_opt strictarr

  n_parameters = n_tags(*self.parameter_distributions)

  if (n_elements(key) eq 0L) then begin
    key = 0L
  endif else begin
    key += 1
    if (key ge self.n_iterations) then return, 0
  endelse

  tnames = tag_names(*self.parameter_distributions)

  value = {}
  for p = 0L, n_parameters - 1L do begin
    distribution = (*self.parameter_distributions).(p)
    value = create_struct(value, tnames[p], (distribution->select(1))[0])
  endfor

  return, 1
end


function mg_randomizedsearchcv::_overloadSize
  compile_opt strictarr

  return, [self.n_iterations]
end


;= lifecycle methods

pro mg_randomizedsearchcv::cleanup
  compile_opt strictarr

  ptr_free, self.parameter_distributions, self.best_parameters, self.best_fit_parameters
  self->mg_predictor::cleanup
end


function mg_randomizedsearchcv::init, predictor, $
                                      n_iterations=n_iterations, $
                                      parameter_distributions=parameter_distributions, $
                                      cross_validation=cross_validation, $
                                      _extra=e
  compile_opt strictarr

  if (~self->mg_predictor::init()) then return, 0

  self->setProperty, _extra=e

  self.type = 'gridsearch'

  self.predictor = predictor
  self.n_iterations = mg_default(n_iterations, 10L)

  self.parameter_distributions = ptr_new(parameter_distributions)
  if (n_elements(cross_validation) eq 0L) then begin
    self.cross_validation = mg_kfoldcv()
  endif else if (obj_valid(cross_validation)) then begin
    self.cross_validation = cross_validation
  endif else begin
    self.cross_validation = mg_kfoldcv(n_splits=cross_validation)
  endelse

  self.best_score = 0.0
  self.best_parameters = ptr_new(/allocate_heap)
  self.best_fit_parameters = ptr_new(/allocate_heap)

  return, 1
end


pro mg_randomizedsearchcv__define
  compile_opt strictarr

  !null = {mg_randomizedsearchcv, inherits mg_predictor, $
           predictor: obj_new(), $
           n_iterations: 0L, $
           parameter_distributions: ptr_new(), $
           cross_validation: obj_new(), $
           best_score: 0.0, $
           best_parameters: ptr_new(), $
           best_fit_parameters: ptr_new()}
end


; main-level example program

; load iris data
iris = mg_learn_dataset('iris')

; pick two of the three species: 0, 1, or 2
species = [1, 2]

; the 150 samples are equally split 50/50/50 into the different species and
; the samples are in order by target
ind = [lindgen(50) + 50 * species[0], lindgen(50) + 50 * species[1]]
data = iris.data[*, ind]
; change to -1 and 1
target = 2 / (species[1] - species[0]) * (iris.target[ind] - species[0]) - 1L
target_names = iris.target_names[species]

; split the dataset into training and test data
seed = 0L
mg_train_test_split, data, target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test, $
                     test_size=0.2, $
                     seed=seed

; instantiate Perceptron model
p = mg_perceptron(max_iterations=20)

param_dists = {max_iterations:mg_uniform_dist([1, 2], type=3L), $
               learning_rate:mg_normal_dist(0.01, 0.005)}
random_search = mg_randomizedsearchcv(p, $
                                      n_iterations=100, $
                                      parameter_distributions=param_dists, $
                                      cross_validation=5)
random_search->fit, x_train, y_train

print, random_search.best_score, format='(%"Best training score: %0.2f")'
print, 'Best parameters:'
help, random_search.best_parameters

y_results = random_search->predict(x_test, y_test, score=score)

print, score, format='(%"Test score with best predictor: %0.2f")'

obj_destroy, random_search

end

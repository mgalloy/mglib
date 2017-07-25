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
pro mg_gridsearchcv::fit, x, y, seed=seed
  compile_opt strictarr

  ; TODO: implement
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
function mg_gridsearchcv::predict, x, y, score=score
  compile_opt strictarr

  ; TODO: implement
end


;= property access

pro mg_gridsearchcv::getProperty, parameter_grid=parameter_grid, $
                                  cross_validation=cross_validation, $
                                  best_score=best_score, $
                                  best_parameters=best_parameters, $
                                  _ref_extra=e
  compile_opt strictarr

  if (arg_present(parameter_grid)) then parameter_grid = *self.parameter_grid
  if (arg_present(cross_validation)) then cross_validation = self.cross_validation
  if (arg_present(best_score)) then best_score = self.best_score
  if (arg_present(best_parameters)) then best_parameters = *self.best_parameters

  if (n_elements(e) gt 0L) then self->mg_estimator::getProperty, _extra=e
end


;= lifecycle methods

pro mg_gridsearchcv::cleanup
  compile_opt strictarr

  ptr_free, self.parameter_grid, self.best_paramaters
  self->mg_estimator::cleanup
end


function mg_gridsearchcv::init, estimator, $
                                parameter_grid=parameter_grid, $
                                cross_validation=cross_validation
  compile_opt strictarr

  if (~self->mg_estimator::init(_extra=e)) then return, 0

  self.type = 'gridsearch'

  self.estimator = estimator
  self.parameter_grid = ptr_new(parameter_grid)
  if (n_elements(cross_validation) eq 0L) then begin
    self.cross_validation = mg_kfoldcv()
  endif else if (obj_valid(cross_validation)) then begin
    self.cross_validation = cross_validation
  endif else begin
    self.cross_validation = mg_kfoldcv(n_splits=cross_validation)
  endelse

  self.best_score = 0.0
  self.best_parameters = ptr_new(/allocate_heap)

  return, 1
end


pro mg_gridsearchcv__define
  compile_opt strictarr

  !null = {mg_gridsearchcv, inherits mg_estimator, $
           estimator: obj_new(), $
           parameter_grid: ptr_new(), $
           cross_validation: obj_new(), $
           best_score: 0.0, $
           best_parameters: ptr_new()}
end


; main-level example program

; load iris data
iris = mg_learn_dataset('iris')

; pick two of the three species: 0, 1, or 2
species = [0, 1]

; the 150 samples are equally split 50/50/50 into the different species and
; the samples are in order by target
ind = [lindgen(50) + 50 * species[0], lindgen(50) + 50 * species[1]]
data = iris.data[*, ind]
target = 2 / (species[1] - species[0]) * (iris.target[ind] - species[0]) - 1L  ; change to -1 and 1
target_names = iris.target_names[species]

; split the dataset into training and test data
;seed = 0L
mg_train_test_split, data, target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test, $
                     test_size=0.2, $
                     seed=seed

; instantiate Perceptron model
p = mg_perceptron(max_iterations=20)

param_grid = {bias: [], $
              learning_rate: []}
grid_search = mg_gridsearchcv(p, parameter_grid=param_grid, cross_validation=5)
grid_search->fit, x_train, y_train
y_results = grid_search->predict(x_test, y_test, score=score)

obj_destroy, grid_search

end

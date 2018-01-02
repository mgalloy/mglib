; docformat = 'rst'

function mg_cross_val_predict, estimator, x, y, $
                               cross_validation=cross_validation
  compile_opt strictarr

  if (n_elements(cross_validation) eq 0L) then begin
    _cross_validation = mg_kfoldcv()
  endif else if (obj_valid(cross_validation)) then begin
    _cross_validation = cross_validation
  endif else begin
    _cross_validation = mg_kfoldcv(n_splits=cross_validation)
  endelse

  y_predict = fltarr(n_elements(y))
  for s = 0L, _cross_validation.n_splits - 1L do begin
    _cross_validation->split, x, y, $
                              training_indices=training_indices, $
                              test_indices=test_indices
    estimator->fit, x[*, training_indices], y[training_indices]
    y_predict[test_indices] = estimator->predict(x[*, test_indices])
  endfor

  if (~obj_valid(cross_validation)) then begin
    obj_destroy, _cross_validation
  endif else begin
    _cross_validation->reset
  endelse

  return, y_predict
end


; main-level example program

boston = mg_learn_dataset('boston')

lsr = mg_ridgeregressor()

mg_train_test_split, boston.data, boston.target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test, $
                     seed=seed

lsr->fit, x_train, y_train
y_predict = lsr->predict(x_test, y_test, score=r2)
print, r2, format='(%"r^2 with standard split: %0.3f")'

cv = mg_kfoldcv(n_splits=3, /shuffle)
y_predict = mg_cross_val_predict(lsr, boston.data, boston.target, cross_validation=cv)

cv_r2 = mg_r2_score(boston.target, y_predict)
print, cv_r2, format='(%"r^2 with cross-validation split: %0.3f")'

obj_destroy, [lsr, cv]

end

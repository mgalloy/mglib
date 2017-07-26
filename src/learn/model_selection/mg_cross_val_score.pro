; docformat = 'rst'

function mg_cross_val_score, estimator, x, y, $
                             cross_validation=cross_validation
  compile_opt strictarr

  if (n_elements(cross_validation) eq 0L) then begin
    _cross_validation = mg_kfoldcv()
  endif else if (obj_valid(cross_validation)) then begin
    _cross_validation = cross_validation
  endif else begin
    _cross_validation = mg_kfoldcv(n_splits=cross_validation)
  endelse

  scores = fltarr(_cross_validation.n_splits)
  for s = 0L, _cross_validation.n_splits - 1L do begin
    _cross_validation->split, x, y, $
                              training_indices=training_indices, $
                              test_indices=test_indices
    estimator->fit, x[*, training_indices], y[training_indices]
    scores[s] = estimator->score(x[*, test_indices], y[test_indices])
  endfor

  if (~obj_valid(cross_validation)) then obj_destroy, _cross_validation

  return, scores
end


; main-level example program

boston = mg_learn_dataset('boston')

lsr = mg_ridgeregressor()

cv = mg_kfoldcv(n_splits=3, /shuffle)
scores = mg_cross_val_score(lsr, boston.data, boston.target, cross_validation=cv)

print, strjoin(string(scores, format='(F0.2)'), ', '), format='(%"Scores: %s")'
print, mean(scores), format='(%"Mean of scores: %0.2f")'

obj_destroy, [lsr, cv]

end

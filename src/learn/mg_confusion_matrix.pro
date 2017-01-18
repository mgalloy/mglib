; docformat = 'rst'

;+
; A confusion matrix `C` is such that `C[i, j]` is equal to the number of
; observations known to be in group `i` but predicted to be in group `j`.
;
; The classes are any value used in `y_true` or `y_predicted` in sorted order.
;
; :Returns:
;   `lonarr(n_classes, n_classes)`
;
; :Params:
;   y_true : in, required, type=lonarr(n_samples)
;     truth (correct) target values
;   y_predict : in, required, type=lonarr(n_samples)
;     predicted target values as returned by a classifier
;
; :Keywords:
;   classes : out, optional, type=lonarr
;     all classes in the order they appear as rows/columns in the confusion
;     matrix
;-
function mg_confusion_matrix, y_true, y_predict, classes=classes
  compile_opt strictarr

  all_values = [y_true, y_predict]
  classes = all_values[uniq(all_values, sort(all_values))]
  n_classes = n_elements(classes)

  cmatrix = lonarr(n_classes, n_classes)
  for r = 0L, n_classes - 1L do begin
    for c = 0L, n_classes - 1L do begin
      !null = where(y_true eq classes[c] and y_predict eq classes[r], count)
      cmatrix[c, r] = count
    endfor
  endfor

  return, cmatrix
end

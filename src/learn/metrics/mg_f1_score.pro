;+
; Returns the f1 score for classification predictors, i.e., the harmonic mean
; of the recall and precision.
;
; :Returns:
;   float/double same as `y_true` and `y_predict`
;
; :Params:
;   y_true : in, required, type=fltarr(n_samples)
;     known `y` values
;   y_predict : in, required, type=fltarr(n_samples)
;     predicted `y` values
;
; :Keywords:
;   positive_label : in, optional, type=integer, default=1
;     label for positive class
;-
function mg_f1_score, y_true, y_predict, positive_label=positive_label
  compile_opt strictarr

  r = mg_recall_score(y_true, y_predict, positive_label=positive_label)
  p = mg_precision_score(y_true, y_predict, positive_label=positive_label)

  return, mg_harmonic_mean([r, p])
end

;+
; Returns the recall score for a classification predictor.
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
function mg_recall_score, y_true, y_predict, positive_label=positive_label
  compile_opt strictarr

  _positive_label = mg_default(positive_label, 1)

  true_ind = where(y_true eq y_predict, n_true, $
                   complement=false_ind, ncomplement=n_false)

  if (n_true gt 0L) then begin
    tp_ind = where(y_predict[true_ind] eq _positive_label, n_tp)
  endif else n_tp = 0L

  if (n_false gt 0L) then begin
    fn_ind = where(y_predict[false_ind] ne _positive_label, n_fn)
  endif else n_fn = 0L

  return, (n_tp + n_fn) eq 0 ? 0.0 : (float(n_tp) / (n_tp + n_fn))
end

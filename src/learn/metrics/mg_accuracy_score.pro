; docformat = 'rst'

;+
; Return classification accuracy.
;
; :Returns:
;   float (if `NORMALIZE` set or float `WEIGHTS` provided) or long (otherwise)
;
; :Params:
;   y_true : in, required, type=lonarr(n_samples)
;     truth (correct) target values
;   y_predict : in, required, type=lonarr(n_samples)
;     predict target values as returned by a classifier
;
; :Keywords:
;   normalize : in, optional, type=boolean
;     set to return a float value between 0.0 and 1.0; otherwise returns an
;     integer between 0 and `n_samples`
;   weights : in, optional, type=fltarr(n_samples)
;     weights to use for each sample
;-
function mg_accuracy_score, y_true, y_predict, normalize=normalize, weights=weights
  compile_opt strictarr

  if (n_elements(weights) eq 0L) then begin
    n_correct = total(y_true eq y_predict, /integer)
    norm = float(n_elements(y_true))
  endif else begin
    n_correct = total(weights * (y_true eq y_predict), /preserve_type)
    norm = float(total(weights, /preserve_type))
  endelse
  
  return, keyword_set(normalize) ? (n_correct / norm) : n_correct
end

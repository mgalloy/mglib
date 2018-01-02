; docformat = 'rst'

;+
; Score for regression predictors.
;
; :Returns:
;   float/double same as `y` and `y_predict`
;
; :Params:
;   y : in, required, type=fltarr(n_samples)
;     known `y` values
;   y_predict : in, required, type=fltarr(n_samples)
;     predicted `y` values
;-
function mg_r2_score, y, y_predict
  compile_opt strictarr

  ss_tot = total((y - mean(y))^2, /preserve_type)
  ss_res = total((y - y_predict)^2, /preserve_type)
  r2 = 1.0 - ss_res / ss_tot

  return, r2
end

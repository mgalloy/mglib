; docformat = 'rst'

;+
; Simple root mean square calculation.
;
; :Returns:
;   float, double, complex, or double complex
;
; :Params:
;   data : in, required, type=numeric data
;     date to determine the room mean square of
;-
function mg_rms, data
  compile_opt strictarr

  return, sqrt(total(data) / n_elements(data))
end

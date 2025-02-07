; docformat = 'rst'

;+
; Calculate median absolute deviation (MAD), i.e.:
;
;   MAD = median(abs(median(x) - x_i))
;
; :Returns:
;   float
;
; :Params:
;   x : in, required, type=fltarr
;     array to calculate MAD of
;-
function mg_mad, x
  compile_opt strictarr

  return, median(abs(median(x) - x))
end

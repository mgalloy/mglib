; docformat = 'rst'

;+
; Calculates the interquartile range (IQR). The distance between 25th and 75th
; percentiles. It is not as prone to issues with outliers.
;
; :Returns:
;   float
;
; :Params:
;   x : in, required, type=fltarr
;     data to calculate IQR of
;-
function mg_iqr, x
  compile_opt strictarr

  percentiles = mg_percentiles(x, percentiles=[0.25, 0.75])
  return, percentiles[1] - percentiles[0]
end

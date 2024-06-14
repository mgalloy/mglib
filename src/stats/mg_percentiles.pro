; docformat = 'rst'

;+
; Calculates given percentiles of a data set.
;
; :Returns:
;   the return value is either a scalar or vector of data values corresponding to
;    the number of percentiles asked for with the `Percentiles` keyword, or a -1 if
;    there is an error in the program.
;
; :Params:
;   data : in, required
;     vector or array to calculate the percentiles from
;
; :Keywords:
;    percentiles : in, optional, type=fltarr, default="[0.25, 0.50, 0.75]"
;      set to a scalar or vector of values between 0.0 and 1.0
;-
function mg_percentiles, data, percentiles=percentiles
  compile_opt strictarr
  on_error, 2

  if (n_elements(data) eq 0L) then message, 'input data is required.'

  _percentiles = mg_default(percentiles, [0.25, 0.50, 0.75])

  ; percentile values must be ge 0 and le 1.0.
  index = where((_percentiles lt 0.0) or (_percentiles gt 1.0), count)
  if (count gt 0L) then message, 'percentiles must be between 0.0 and 1.0.'

  n = n_elements(data)

  ; sort the data and find percentiles
  sort_indices = sort(data)
  indices = value_locate(findgen(n + 1) / n, _percentiles)
  result = data[sort_indices[indices]]

  return, result
end


; main-level example program

n = 10000L
x = randomn(seed, n)
print, mg_range(x), median(x)
p = mg_percentiles(x, percentiles=findgen(11) / 10.0)
print, p

end

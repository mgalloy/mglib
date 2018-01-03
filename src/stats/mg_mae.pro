; docformat = 'rst'

;+
; Simple mean absolute error calculation.
;
; :Returns:
;   float, double, complex, or double complex
;
; :Params:
;   data1 : in, required, type=numeric data
;     data1 to determine the mean absolute value
;   data2 : in, optional, type=numeric data
;     if present, calculate the mean absoulte value of `data1 - data2`
;
; :Keywords:
;   nan : in, optional, type=boolean
;     set to include only finite data
;   weights : in, optional, type=float/double
;     set to value to multiply the absolute values by
;-
function mg_mae, data1, data2, weights=weights, nan=nan
  compile_opt strictarr

  _data = n_params() eq 2L ? (data1 - data2) : data1
  _weights = n_elements(weights) ne 0L ? weights : (0.0 * data1 + 1.0)

  if (keyword_set(nan)) then begin
    finite_indices = where(finite(_data), n_finite)

    type = size(_data, /type)
    if (n_finite eq 0L) then begin
      return, (type eq 4 || type eq 6) ? !values.f_nan : !values.d_nan
    endif

    return, sqrt(total(_weights[finite_indices] * abs(_data[finite_indices])) / n_finite)
  endif else begin
    return, sqrt(total(_weights * abs(_data)) / n_elements(_data))
  endelse
end

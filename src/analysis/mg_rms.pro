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
;
; :Keywords:
;   nan : in, optional, type=boolean
;     set to include only finite data
;-
function mg_rms, data, nan=nan
  compile_opt strictarr

  if (keyword_set(nan)) then begin
    finite_indices = where(finite(data), n_finite)

    type = size(data, /type)
    if (n_finite eq 0L) then begin
      return, type eq 4 || type eq 6 ? !values.f_nan : !values.d_nan
    endif

    return, sqrt((total(data[finite_indices]))^2 / n_finite)
  endif else begin
    return, sqrt((total(data))^2 / n_elements(data))
  endelse
end

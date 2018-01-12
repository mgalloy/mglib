; docformat = 'rst'

;+
; Convenience function to compute the minimum and maximm value of an array.
;
; :Examples:
;   For example, find the minimum and maximum values of 10 random values::
;
;     IDL> print, mg_range(randomu(0L, 10))
;         0.0668422     0.930436
;
; :Returns:
;   `fltarr(2)`
;
; :Params:
;   arr : in, required, type=any numeric array
;     variable to compute min/max range of
;-
function mg_range, arr, _extra=e
  compile_opt strictarr

  return, [min(arr, max=maxValue, _extra=e), maxValue]
end

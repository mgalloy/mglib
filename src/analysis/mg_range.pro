; docformat = 'rst'

;+
; Convenience function to compute the minimum and maximm value of an array.
;
; :Examples:
;   For example, find the minimum and maximum values of 10 random values::
;
;       IDL> print, mg_range(randomu(0L, 10))
;           0.0668422     0.930436
;
; :Returns:
;    `fltarr(2)` or `fltarr(2, n)` where `n` is the size of the dimension which
;    the range is performed on
;
; :Params:
;    arr : in, required, type=any numeric array
;       variable to compute min/max range of
;
; :Keywords:
;   dimension : in, optional, type=integer, default=0
;     dimension to compute min/max over, 0 indicates the entire array
;-
function mg_range, arr, dimension=dimension
  compile_opt strictarr

  min_value = min(arr, max=max_value, dimension=dimension)
  if (n_elements(dimension) eq 0L || dimension eq 0) then begin
    return, [min_value, max_value]
  endif else begin
    return, transpose([[min_value], [max_value]])
  endelse
end

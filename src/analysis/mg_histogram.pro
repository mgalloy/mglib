; docformat = 'rst'

;+
; Wrapper to `HISTOGRAM` function with added functionality.
;
; :Returns:
;   array
;
; :Params:
;   data : in, required, type=array
;     data to histogram
;
; :Keywords:
;   bin_edges : in, optional, type=array
;     array values to use to divide the range into bins; there will be one more
;     histogram value than the number of elements in `bin_edges`
;   _ref_extra : in, out, optional, type=keyword
;     keywords to `HISTOGRAM`
;-
function mg_histogram, data, $
                       bin_edges=bin_edges, $
                       _ref_extra=e
  compile_opt strictarr

  ; use bin_edges to create histogram with unequal bin sizes
  if (n_elements(bin_edges) gt 0L) then begin
    bins = value_locate(bin_edges, data, _extra=e)
    h = histogram(bins, _extra=e)
    return, h
  endif

  return, histogram(data, _extra=e)
end

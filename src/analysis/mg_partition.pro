; docformat = 'rst'

;+
; Determine the size of partitions of `x` where each sum of each partition is
; less than `max_size`.
;
; :Returns:
;   `lonarr`
;
; :Params:
;   x : in, required, type=1d numeric array
;     array to partition
;   max_size : in, required, type=numeric
;     maximum size of the sum of each partition
;-
function mg_partition, x, max_size
  compile_opt strictarr

  csum = total(x, /cumulative, /preserve_type)
  ind = where(csum gt max_size, count)

  if (count eq 0L) then return, [n_elements(x)] else begin
    return, [ind[0], mg_partition(x[ind[0]:*], max_size)]
  endelse
end

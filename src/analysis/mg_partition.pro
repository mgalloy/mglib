; docformat = 'rst'

;+
; Determine the size of partitions of `x` where the sum of each partition is
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
;
; :Keywords:
;   count : out, optional, type=integer
;     set to a named variable to retrieve the number of partions
;-
function mg_partition, x, max_size, count=count
  compile_opt strictarr

  csum = total(x, /cumulative, /preserve_type)
  ind = where(csum gt max_size, n_next_partition)

  if (n_next_partition eq 0L) then begin
    count = 1L
    return, [n_elements(x)]
  endif else begin
    partitions = [ind[0], mg_partition(x[ind[0]:*], max_size, count=count)]
    count += 1
    return, partitions
  endelse
end


; main-level example program

x = [25, 50, 17, 30, 55, 10, 25, 75]
partitions = mg_partition(x, 100, count=n_partitions)
print, n_partitions, format='(%"n_partitions: %d")'
print, strjoin(strtrim(partitions, 2), ', '), format='(%"partitions: %s")'

i = 0L
for p = 0L, n_partitions - 1L do begin
  print, p, strjoin(strtrim(x[i:partitions[p] + i - 1], 2), ', '), $
         format='(%"partition %d: %s")'
  i += partitions[p]
endfor

end

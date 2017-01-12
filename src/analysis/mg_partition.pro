; docformat = 'rst'


;+
; Recursive helper function to `MG_PARTITION`.
;
; :Private:
;
; :Params:
;   x : in, required, type=1d numeric array
;     array to partition
;   max_size : in, required, type=numeric
;     maximum size of the sum of each partition
;-
function mg_partition_helper, x, max_size
  compile_opt strictarr

  csum = total(x, /cumulative, /preserve_type)
  ind = where(csum gt max_size, n_next_partition)

  if (n_next_partition eq 0L) then return, [n_elements(x)] else begin
    ; there might be an element that is bigger than max_size, if so just put it
    ; in its own partition -- that's the best we can do
    if (ind[0] eq 0L) then begin
      return, [1L, mg_partition_helper(x[1:*], max_size)]
    endif else begin
      return, [ind[0], mg_partition_helper(x[ind[0]:*], max_size)]
    endelse
  endelse
end


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
;     set to a named variable to retrieve the number of partitions
;   indices : out, optional, type=lonarr
;     set to a named variable to retrieve the indices
;-
function mg_partition, x, max_size, count=count, indices=indices
  compile_opt strictarr

  partitions = mg_partition_helper(x, max_size)
  count = n_elements(partitions)

  if (arg_present(indices)) then begin
    indices = [0L, total(partitions, /preserve_type, /cumulative)]
  endif

  return, partitions
end


; main-level example program

x = [25, 50, 17, 30, 55, 10, 25, 75]
partitions = mg_partition(x, 100, count=n_partitions, indices=ind)
print, n_partitions, format='(%"n_partitions: %d")'
print, strjoin(strtrim(partitions, 2), ', '), format='(%"partitions: %s")'

for p = 0L, n_partitions - 1L do begin
  print, p, strjoin(strtrim(x[ind[p]:ind[p + 1] - 1], 2), ', '), $
         format='(%"partition %d: %s")'
endfor

end

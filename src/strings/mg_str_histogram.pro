; docformat = 'rst'

;+
; Calculate a histogram with the same interface as `HISTOGRAM`.
;
; :Returns:
;   lonarr
;
; :Params:
;   values : in, required, type=strarr
;     string array of values
;
; :Keywords:
;   reverse_indices : out, optional, type=lonarr
;     set to a named variable to retrieve the indices of the original array
;     that fall into each bin of the histogram in the same notation used as
;     `HISTOGRAM`
;   locations : out, optional, type=strarr
;     set to a named variable to retrieve the unique elements of `values` that
;     the bins of the histogram refer to
;-
function mg_str_histogram, values, $
                           reverse_indices=reverse_indices, $
                           locations=locations
  compile_opt strictarr

  h = hash()

  for i = 0L, n_elements(values) - 1L do begin
    if (h->hasKey(values[i])) then begin
      (h[values[i]])->add, i
    endif else begin
      h[values[i]] = list(i)
    endelse
  endfor

  n_unique_values = h->count()
  hist = lonarr(n_unique_values)

  keys_list = h->keys()
  if (arg_present(locations)) then begin
    locations = keys_list->toArray()
  endif

  if (arg_present(reverse_indices)) then begin
    reverse_indices = lonarr(n_unique_values + 1L + n_elements(values))
    reverse_indices[0] = n_unique_values + 1L
  endif

  j = n_unique_values
  foreach k, keys_list, i do begin
    hist[i] = (h[k])->count()
    if (arg_present(reverse_indices)) then begin
      reverse_indices[i + 1] = reverse_indices[i] + hist[i]
      reverse_indices[reverse_indices[i]] = (h[k])->toArray()
    endif
  endforeach

  obj_destroy, [h, keys_list]
  return, hist
end


; main-level example program

;v = ['a', 'a', 'b', 'b', 'c']
;v = ['a', 'b', 'a', 'b', 'c']
v = ['c', 'b', 'a', 'a', 'b', 'c', 'a', 'd']

h = mg_str_histogram(v, locations=locs, reverse_indices=ri)
print, v
print, h
print, locs
print, ri

end

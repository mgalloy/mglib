; docformat = 'rst'

;+
; Count the frequency of the values of a given array of strings.
;
; :Private:
;
; :Returns:
;   array of structures with fields 'value' and 'count' where value is the same
;   type as `x`
;
; :Params:
;   x : in, required, type=integer/string array
;     array to count frequency of values in
;-
function mg_frequency_string, x
  compile_opt strictarr

  sorted_ind = sort(x)
  unique_ind = uniq(x, sorted_ind)
  n = n_elements(unique_ind)
  result = replicate({value: '', count: 0L}, n)
  for i = 0L, n - 1L do begin
    ind = where(x eq x[unique_ind[i]], n_i)
    result[i].value = x[unique_ind[i]]
    result[i].count = n_i
  endfor
  return, result
end


;+
; Count the frequency of the values of a given array of integer type.
;
; :Private:
;
; :Returns:
;   array of structures with fields 'value' and 'count' where value is the same
;   type as `x`
;
; :Params:
;   x : in, required, type=integer/string array
;     array to count frequency of values in
;-
function mg_frequency_integer, x
  compile_opt strictarr

  h = histogram(x, min=min(x), max=max(x), binsize=1L, reverse_indices=ri)
  ind = where(h gt 0L, n)
  result = replicate({value: x[0], count: 0L}, n)
  result.value = x[ri[ri[0:n - 1]]]
  result.count = h[ind]
  return, result
end


;+
; Count the frequency of the values of a given array.
;
; :Examples:
;   For example::
;
;     IDL> print, mg_table(mg_frequency(long(5 * randomu(seed, 100))))
;                  0            1
;       ============ ============
;     0            0           25
;     1            1           21
;     2            2           16
;     3            3           13
;     4            4           25
;
; :Returns:
;   array of structures with fields 'value' and 'count' where value is the same
;   type as `x`
;
; :Params:
;   x : in, required, type=integer/string array
;     array to count frequency of values in
;-
function mg_frequency, x
  compile_opt strictarr

  if (size(x, /type) eq 7) then begin
    return, mg_frequency_string(x)
  endif else begin
    return, mg_frequency_integer(x)
  endelse
end

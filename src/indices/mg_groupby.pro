; docformat = 'rst'

;+
; Group a vector array by equal values.
;
; :Examples:
;   Given the following call of `MG_GROUPBY`::
;
;     group_indices = mg_groupby(x, group_starts=group_starts)
;
;   the way to retrieve the contens of group `g` is::
;
;     x[group_indices[group_starts[g]:group_starts[g+1] - 1L]]
;
; :Returns:
;   `lonarr` with same length as `x` representing indices into `x`
;
; :Params:
;   x : in, required, type=numeric or string
;     input to group
;
; :Keywords:
;   n_groups : out, optional, type=long
;     set to a named variable to retrieve the number of groups in the result
;   group_starts : out, optional, type="lonarr(n_groups + 1)"
;     set to a named variable to retrieve indices into the group indices return
;     value indicating the beginning index of each group
;-
function mg_groupby, x, n_groups=n_groups, group_starts=group_starts
  compile_opt strictarr

  indices = uniq(x, sort(x))

  n_groups = n_elements(indices)
  group_indices = lonarr(n_elements(x))
  group_starts = lonarr(n_groups + 1)

  for i = 0L, n_groups - 1L do begin
    ind = where(x eq x[indices[i]], count)
    group_indices[group_starts[i]] = ind
    group_starts[i + 1L] = count + group_starts[i]
  endfor

  return, group_indices
end


; main-level example program

x1 = [0, 5, 7, 7, 8, 9, 9, 9]
x2 = [1.0, 2.0, 3.0, 4.5, 4.5, 1.0, 7.0, 1.0]
x3 = strtrim(x1, 2) + '-' + string(x2, format='(%"%0.2f")')

x = x3

group_indices = mg_groupby(x, n_groups=n_groups, group_starts=group_starts)
print, strjoin(x, ', ')
print
for g = 0L, n_groups - 1L do begin
  print, strjoin(x[group_indices[group_starts[g]:group_starts[g+1] - 1L]], ', ')
endfor

end

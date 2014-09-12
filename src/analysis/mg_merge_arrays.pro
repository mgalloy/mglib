; docformat = 'rst'

;+
; Merge two arrays and remove duplicates.
;
; :Private:
;
; :Returns:
;   array of same type as input arrays
;
; :Params:
;   arr1 : in, required, type=numeric array
;     first array to merge
;   arr2 : in, required, type=numeric array
;     second array to merge
;
; :Keywords:
;   indices : out, optional, type=lonarr
;     indices of original merged array `[arr1, arry2]`
;-
function mg_merge_arrays, arr1, arr2, indices=indices
  compile_opt strictarr

  all = [arr1, arr2]
  sorted_inds = sort(all)
  indices = uniq(all, sorted_inds)

  return, all[indices]
end

; docformat = 'rst'

;+
; Returns the complement of an index array.
;
; :Examples:
;   For example, try::
;
;     IDL> print, mg_complement([0, 9, 3, 6, 7], 10)
;                1           2           4           5           8
;     IDL> print, mg_complement(-1, 5) 
;                0           1           2           3           4
;
; :Returns:
;   `lonarr` or `-1L` if complement is empty
;
; :Params:
;   indices : in, required, type=lonarr
;     indices to complement; -1 or `!null` indicates an empty array of indices
;   n : in, required, type=integer/array
;     full array or number of elements in full array
;
; :Keywords:
;   count : out, optional, type=long
;     set to a named variable to return the number of elements in the
;     complement
;-
function mg_complement, indices, n, count=ncomplement
  compile_opt strictarr, strictarrsubs

  _n = size(n, /n_dimensions) eq 0L ? n : n_elements(n)

  all = bytarr(_n)
  if (n_elements(indices) gt 0L) then begin
    valid_indices = where(indices ge 0 and indices lt _n, n_valid)
    if (n_valid gt 0L) then all[indices[valid_indices]] = 1B
  endif

  return, where(all eq 0B, ncomplement)
end

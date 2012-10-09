; docformat = 'rst'

;+
; Returns the complement of an index array.
;
; :Examples:
;    For example, try::
;
;       IDL> print, mg_complement([0, 9, 3, 6, 7], 10)
;                  1           2           4           5           8
;
; :Returns:
;    `lonarr` or `-1L` if complement is empty
;
; :Params:
;    indices : in, required, type=lonarr
;       indices to complement
;    n : in, required, type=integer type
;       number of elements in full array
;
; :Keywords:
;    count : out, optional, type=long
;       set to a named variable to return the number of elements in the
;       complement
;-
function mg_complement, indices, n, count=ncomplement
  compile_opt strictarr

  all = bytarr(n)
  if (indices[0] ne -1L) then all[indices] = 1B
  return, where(all eq 0B, ncomplement)
end

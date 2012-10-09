; docformat = 'rst'

;+
; Find the union of two sets of indices. A set of indices is represented by an
; array of non-negative integers where a scalar `-1L` indicates the empty set.
;
; :Examples:
;    For example, try::
;
;       IDL> print, mg_setunion([0, 3, 5, 9], [3, 5, 7])
;                  0           3           5           7           9
;
; :Returns:
;    `lonarr` or `-1L`
;
; :Params:
;    ind1 : in, required, type=lonarr or -1L
;       array of indices where -1L` indicates an empty set of indices
;    ind2 : in, required, type=lonarr or -1L
;       array of indices where `-1L` indicates an empty set of indices
;
; :Keywords:
;    count : out, optional, type=long
;       set to a named variable to return the number of elements in the union
;-
function mg_setunion, ind1, ind2, count=count
  compile_opt strictarr

  if (ind1[0] lt 0L) then begin
    count = ind2[0] lt 0L ? 0L : n_elements(ind2)
    return, ind2
  endif

  if (ind2[0] lt 0L) then begin
    count = n_elements(ind1)
    return, ind1
  endif

  union = where(histogram([ind1, ind2], omin=omin)) + omin
  count = n_elements(union)

  return, union
end

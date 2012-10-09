; docformat = 'rst'

;+
; Find the intersection of two sets of indices. A set of indices is
; represented by an array of non-negative integers where a scalar `-1L`
; indicates the empty set.
;
; :Examples:
;    For example, try::
;
;       IDL> print, mg_setintersection([0, 3, 5, 6, 9], [3, 5, 7])
;                  3           5
;
; :Returns:
;    `lonarr` or `-1L`
;
; :Params:
;    ind1 : in, required, type=lonarr or -1L
;       array of indices where `-1L` indicates an empty set of indices
;    ind2 : in, required, type=lonarr or -1L
;       array of indices where `-1L` indicates an empty set of indices
;
; :Keywords:
;    count : out, optional, type=long
;       set to a named variable to return the number of elements in the
;       intersection
;-
function mg_setintersection, ind1, ind2, count=count
  compile_opt strictarr

  min12 = min(ind1, max=max1) > min(ind2, max=max2)
  max12 = max1 < max2

  ; if either set is empty or their ranges don't intersect results in an
  ; empty set
  if ((max12 lt min12) || (max12 lt 0L)) then begin
    count = 0L
    return, -1L
  endif

  r = where((histogram([ind1], min=min12, max=max12) ne 0L) and  $
            (histogram([ind2], min=min12, max=max12) ne 0L), count)

  return, count eq 0L ? -1L : (r + min12)
end

; docformat = 'rst'

;+
; Find the difference of two sets of indices. A set of indices is
; represented by an array of non-negative integers where a scalar `-1L`
; indicates the empty set.
;
; :Examples:
;   For example, try::
;
;     IDL> print, mg_setdifference([0, 3, 5, 6, 9], [3, 5])
;                0           6           9
;
; :Returns:
;   `lonarr` or `-1L`
;
; :Params:
;   ind1 : in, required, type=lonarr or -1L
;     array of indices where `-1L` indicates an empty set of indices
;   ind2 : in, required, type=lonarr or -1L
;     array of indices where `-1L` indicates an empty set of indices
;
; :Keywords:
;   count : out, optional, type=long
;     set to a named variable to return the number of elements in the
;     difference
;-
function mg_setdifference, ind1, ind2, count=count
  compile_opt strictarr

  min1 = min(ind1, max=max1)
  min2 = min(ind2, max=max2)

  ; empty set difference if ind1 is empty
  if (ind1[0] eq -1L) then begin
    count = 0L
    return, -1L
  endif

  ; return ind1 if no intersection of ranges
  if ((min2 gt max1) || (max2 lt min1)) then begin
    count = n_elements(ind1) eq 0L ? 0L : n_elements(ind1)
    return, ind1
  endif

  r = where((histogram([ind1], min=min1, max=max1) ne 0L) and $
            (histogram([ind2], min=min1, max=max1) eq 0L), count)

  return, count eq 0L ? -1L : (r + min1)
end

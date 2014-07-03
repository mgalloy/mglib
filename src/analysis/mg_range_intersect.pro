; docformat = 'rst'

;+
; Intersecy two ranges together to get a new range.
;
; :Returns:
;   2-element numeric array or `!null`
;
; :Params:
;   r1 : in, required, type=2-element numeric array
;     first range
;   r2 : in, required, type=2-element numeric array
;     second range
;
; :Keywords:
;   is_empty : out, optional, type=boolean
;     set to a named variable to return whether the intersection of the two
;     ranges is empty (`!null` is returned in this case)
;-
function mg_range_intersect, r1, r2, is_empty=is_empty
  compile_opt strictarr

  result = [r1[0] > r2[0], r1[1] < r2[1]]
  is_empty = result[1] lt result[0]
  return, is_empty ? !null : result
end
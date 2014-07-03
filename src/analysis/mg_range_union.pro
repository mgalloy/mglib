; docformat = 'rst'

;+
; Union two ranges together to get a new range.
;
; :Returns:
;   2-element numeric array
;
; :Params:
;   r1 : in, required, type=2-element numeric array
;     first range
;   r2 : in, required, type=2-element numeric array
;     second range
;
; :Keywords:
;   has_hole : out, optional, type=boolean
;     set to a named variable to return whether the union of the two ranges has
;     a whole in it
;-
function mg_range_union, r1, r2, has_hole=has_hole
  compile_opt strictarr

  has_hole = r1[1] lt r2[0] || r2[1] lt r1[0]
  return, [r1[0] < r2[0], r1[1] > r2[1]]
end

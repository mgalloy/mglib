; docformat = 'rst'

;+
; Compute the min/max range of a variable.
;
; :Returns:
;    fltarr(2)
;
; :Params:
;    var : in, required, type=any numeric array
;       variable to compute min/max range of
;-
function vis_range, var
  compile_opt strictarr
  
  maxValue = max(var, min=minValue)
  return, [minValue, maxValue]
end
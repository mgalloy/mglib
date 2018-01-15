; docformat = 'rst'

;+
; Rectified linear unit, max of given input `x` and 0.
;
; :Returns:
;   array of the same size and type as `x`
;
; :Params:
;   x : in, required, type=numeric array
;     input array
;-
function mg_relu, x
  compile_opt strictarr

  return, x > 0
end

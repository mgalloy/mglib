; docformat = 'rst'

;+
; Logistic function, the derivative of the softmax function::
;
;   1 / (1 + e^{-x})
;
; :Returns:
;   array of the same size and type as `x`
;
; :Params:
;   x : in, required, type=numeric array
;     input array
;-
function mg_logistic, x
  compile_opt strictarr

  return, 1 / (1 + exp(-x))
end

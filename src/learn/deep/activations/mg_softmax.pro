; docformat = 'rst'

;+
; Softmax function::
;
;   log(1 + e^x)
;
; :Returns:
;   array of the same size and type as `x`
;
; :Params:
;   x : in, required, type=numeric array
;     input array
;-
function mg_softmax, x
  compile_opt strictarr

  return, alog(1 + exp(x))
end

; docformat = 'rst'

;+
; Finds the next power of 2. Returns the input value if it is already a power
; of 2.
;
; :Returns:
;    integer of the same type as the input `x`
;
; :Params:
;    x : in, required, type=integer type
;       input value
;-
function mg_power2, x
  compile_opt strictarr

  n = x - 1L
  n = ishft(n,  -1) or n
  n = ishft(n,  -2) or n
  n = ishft(n,  -4) or n
  n = ishft(n,  -8) or n
  n = ishft(n, -16) or n
  n = ishft(n, -32) or n
  n = ishft(n, -64) or n

  return, ++n
end

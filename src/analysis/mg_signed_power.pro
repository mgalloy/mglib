; docformat = 'rst'

;+
; Apply a power to signed data for display purposes.
;
; :Returns:
;   numeric array
;
; :Params:
;   x : in, required, type=numeric array
;     array with potential negative values to be taken to a power
;   power : in, required, type=float
;     exponent to raise `x` to
;-
function mg_signed_power, x, power
  compile_opt strictarr

  negative_indices = where(x lt 0.0, n_negative_indices)

  _x = x
  if (n_negative_indices gt 0L) then begin
    _x[negative_indices] = - _x[negative_indices]
  endif

  result = _x^power
  if (n_negative_indices gt 0L) then begin
    result[negative_indices] = - result[negative_indices]
  endif

  return, result
end

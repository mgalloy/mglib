; docformat = 'rst'

;+
; Return the sign of the values of an array: -1 for negative values, 0 for
; 0 values, 1 for positive values. The dimensions of the result are the same
; as the input array.
;
; :Examples:
;    For example, the following finds the sign of the values in a simple
;    array::
;
;       IDL> print, mg_sign([-3.5, 0., 4.7])
;             -1       0       1
;
; :Returns:
;    intarr
;
; :Params:
;    x : in, required, type=numeric array
;       input array
;-
function mg_sign, x
  compile_opt strictarr

  return, fix(x gt 0) - fix(x lt 0)
end
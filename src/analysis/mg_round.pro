; docformat = 'rst'

;+
; Rounds value to integer value (or to nearest float value). Allows rounding
; to nearest `roundTo` value, i.e., round to the nearest `0.1`.
;
; :Returns:
;    numeric
;
; :Params:
;    x : in, required, type=numeric (array)
;       value to round
;    roundTo : in, optional, type=numeric scalar, default=1
;       value to round to
;
; :Keywords:
;    l64 : in, optional, type=boolean
;       set to return result as a 64-bit integer
;-
function mg_round, x, roundTo, l64=l64
  compile_opt strictarr
  on_error, 2

  case n_params() of
    1: return, round(x, l64=l64)
    2: return, round(x / roundTo) * roundTo
    else: message, 'invalid number of parameters'
  endcase
end


; main-level example

print, mg_round(3.5)
print, mg_round(3.5, 0.25)
print, mg_round(3.7, 0.25)
print, mg_round(3.62378562835, 0.001)

end

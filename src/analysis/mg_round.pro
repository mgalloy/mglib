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
;    round_to : in, optional, type=numeric scalar, default=1
;       value to round to
;
; :Keywords:
;    l64 : in, optional, type=boolean
;       set to return result as a 64-bit integer
;-
function mg_round, x, round_to, l64=l64
  compile_opt strictarr
  on_error, 2

  if (n_elements(round_to) eq 0L) then begin
    return, round(x, l64=l64)
  endif else begin
    return, round(x / round_to) * round_to
  endelse
end


; main-level example

print, mg_round(3.5)
print, mg_round(3.5, 0.25)
print, mg_round(3.7, 0.25)
print, mg_round(3.62378562835, 0.001)

end

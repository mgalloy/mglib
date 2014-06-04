; docformat = 'rst'

;+
; Determine whether any elements of an array of logical values is true.
;
; :Examples:
;   For example, determine if there are any elements between 0.1 and 0.2 (or
;   between 0.6 and 0.7)::
;
;     IDL> x = randomu(seed, 10)
;     IDL> print, x
;          0.882556     0.573106     0.778631     0.663021     0.869744
;          0.026374     0.750390     0.655109     0.979332     0.512633
;     IDL> print, mg_any(x gt 0.1 and x lt 0.2)
;        0
;     IDL> print, mg_any(x gt 0.6 and x lt 0.7)
;        1
;
;
; :Returns:
;   0B or 1L
;
; :Params:
;   condition : in, required, type=numeric array
;     array of conditions to check
;
; :Keywords:
;   indices : out, optional, type=lonarr
;     array of indices of true values in `condition`
;-
function mg_any, condition, indices=indices
  compile_opt strictarr

  indices = where(condition, count)
  return, count gt 0L
end


; main-leve example program

x = randomu(seed, 10)
print, mg_any(x gt 0.1 and x lt 0.2)
print, mg_any(x gt 0.6 and x lt 0.7)

end
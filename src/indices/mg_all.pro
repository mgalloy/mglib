; docformat = 'rst'

;+
; Determine whether all elements of an array of logical values are true.
;
; :Examples:
;   For example, determine if there are any even integers in any array and if
;   all integers in the array are even::
;
;     IDL> a = indgen(10)
;     IDL> print, mg_any(a mod 2 eq 0)
;        1
;     IDL> print, mg_all(a mod 2 eq 0)
;        0
;
; :Returns:
;   0B or 1L
;
; :Params:
;   condition : in, required, type=numeric array
;     array of conditions to check
;-
function mg_all, condition
  compile_opt strictarr

  ind = where(condition, count)
  return, count eq n_elements(condition)
end


; main-level example program

a = indgen(10)
print, mg_any(a mod 2 eq 0)
print, mg_all(a mod 2 eq 0)

end

; docformat = 'rst'

;+
; Determines if a year is a leap year.
;
; :Returns:
;   `0B` or `1B`
;
; :Params:
;   year : in, required, type=integer
;     year to check
;-
function mg_is_leap_year, year
  compile_opt strictarr

  return, (year mod 4 eq 0) && ((year mod 100 ne 0L) || (year mod 400 eq 0L))
end

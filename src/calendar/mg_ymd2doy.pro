; docformat = 'rst'

;+
; Convert a year-month-day to a day of the year.
;
; :Returns:
;   integer
;
; :Params:
;   year : in, required, type=integer
;     year
;   month : in, required, type=integer
;     month
;   day : in, required, type=integer
;     day
;-
function mg_ymd2doy, year, month, day
  compile_opt strictarr

  ; days before start of each month (non-leap year)
  idays = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 366]
  is_leapyear = (year mod 4 eq 0) and (year mod 100 ne 0) or (year mod 400 eq 0)
  is_leapyear and= month ge 3

  return, day + idays[month - 1] + is_leapyear
end

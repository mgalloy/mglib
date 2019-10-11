; docformat = 'rst'

;+
; Give the number of days in a month for a given year.
;
; :Returns:
;   long
;
; :Params:
;   year : in, required, type=long
;     year
;   month : in, required, type=long
;     month, 1-12
;-
function mg_month_days, year, month
  compile_opt strictarr

  days = [31L, 28L, 31L, 30L, 31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L]
  if (mg_is_leap_year(year)) then days[1] += 1L

  return, days[month - 1L]
end

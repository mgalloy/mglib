; docformat = 'rst'

;+
; Convert a year and day of year to a year-month-day.
;
; :Params:
;   year : in, required, type=integer
;     year
;   doy : in, required, type=integer
;     day of year
;
; :Keywords:
;   year : out, optional, type=integer
;     output year, could differ from `year` parameter if `doy` is
;     negative or greater than 365/366
;   month : out, optional, type=integer
;     output month
;   day : out, optional, type=integer
;     output day
;-
pro mg_doy2ymd, year, doy, year=output_year, month=month, day=day
  compile_opt strictarr

  jd = julday(1, doy, year)
  caldat, jd, month, day, output_year
end

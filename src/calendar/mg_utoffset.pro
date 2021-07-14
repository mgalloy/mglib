; docformat = 'rst'

;+
; Determine the local offset from UT time.
;
; :Returns:
;   number of hours offset as a double
;-
function mg_utoffset
  compile_opt strictarr

  ut_timestamp = timestamp()
  local_julian = julday()

  timestamptovalues, ut_timestamp, $
                     year=ut_year, month=ut_month, day=ut_day, $
                     hour=ut_hour, minute=ut_minute, second=ut_second
  ut_julian = julday(ut_month, ut_day, ut_year, ut_hour, ut_minute, ut_second)

  return, mg_round(24.0D * (local_julian - ut_julian), 0.25)
end

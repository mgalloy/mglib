; docformat = 'rst'

;+
; Return a string representing a Julian date using a subset of the C strftime
; format codes.
;
; Accepted codes: %y, %Y, %d, %a, %m, %b, %j, %H, %I, %M, %S, %f, %p, %c, %x,
; and %X.
;
; :Returns:
;   string
;
; :Params:
;   date : in, required, type=double
;     date/time structure of the form::
;
;       {year:0L, month:0L, day:0L, hour:0L, minute:0L, second:0.0D}
;
;   format : in, required, type=string
;     format specification
;-
function mg_strftime, date, format
  compile_opt strictarr

  jd = julday(date.month, date.day, date.year, date.hour, date.minute, date.second)

  ; find information
  caldat, jd, month, day, year, hour, minute, second
  day_of_week = string(jd, format='(C(CDwA))')
  month_name = string(jd, format='(C(CMoA))')
  ampm = string(jd, format='(C(CAPA))')

  ; perform substitution
  result = format
  s = hash('%y', string(date.year mod 100, format='(%"%02d")'), $
           '%Y', string(date.year, format='(%"%04d")'), $
           '%d', string(date.day, format='(%"%02d")'), $
           '%a', day_of_week, $
           '%m', string(date.month, format='(%"%02d")'), $
           '%b', month_name, $
           '%j', string(mg_ymd2doy(date.year, date.month, date.day), format='(%"%03d")'), $
           '%H', string(date.hour, format='(%"%02d")'), $
           '%I', string((date.hour gt 12) ? (date.hour - 12) : date.hour, format='(%"%02d")'), $
           '%M', string(date.minute, format='(%"%02d")'), $
           '%S', string(date.second, format='(%"%02d")'), $
           '%f', string(1000000L * (date.second - long(date.second)), format='(%"%06d")'), $
           '%p', ampm, $
           '%c', string(day_of_week, $
                        month_name, $
                        date.day, $
                        date.hour, date.minute, date.second, $
                        date.year, $
                        format='(%"%s %s %02d %02d:%02d:%02d %04d")'), $
           '%x', string(date.month, date.day, date.year, format='(%"%02d/%02d/%04d")'), $
           '%X', string(date.hour, date.minute, date.second, format='(%"%02d:%02d:%02d")'))
  foreach value, s, code do result = mg_streplace(result, code, value, /global)

  return, result
end


; main-level example program

print, mg_strftime(systime(/julian), '%a %b %d %H:%M:%S %Y -- %Y%m%d.%H%M%S %p')

end

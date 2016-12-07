; docformat = 'rst'

;+
; Returns the current date/time.
;
; :Returns:
;   structure of the form::
;
;     {year:0L, month:0L, day:0L, hour:0L, minute:0L, second:0.0D}
;
; :Keywords:
;   utc : in, optional, type=boolean
;     set to find current UTC time
;-
function mg_localtime, utc=utc
  compile_opt strictarr

  now = systime(/julian, utc=utc)
  caldat, now, month, day, year, hour, minute, second
  return, {year:year, $
           month:month, $
           day:day, $
           hour:hour, $
           minute:minute, $
           second:second}
end

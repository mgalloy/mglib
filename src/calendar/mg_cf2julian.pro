; docformat = 'rst'


;+
; Convert a time value from `CF conventions <cfconventions.org>` to a Julian
; date.
;
; :Returns:
;   double/`dblarr`
;
; :Params:
;   cf_time : in, required, type=numeric
;     time in seconds/minutes/hours/days since a starting time
;
; :Keywords:
;   units : in, required, type=string
;     string describing units in CF convention; must be in the form::
;
;       seconds since 1970-1-1 00:00:00.0 -000
;
;     where hours/minutes/seconds and timezone is optional (defaults to
;     midnight and UTC)
;   error : out, optional, type=long
;     set to a named variable to retrieve an error status; if passed in, will
;     not use `MESSAGE` to throw errors
;-
function mg_cf2julian, cf_time, units=units, error=error
  compile_opt strictarr
  on_error, 2

  error = 0L

  year = 0L
  month = 0L
  day = 0L
  hour = 0L
  minute = 0L
  second = 0.0D

  units_tokens = strsplit(units, /extract, count=n_units_tokens)

  if (n_units_tokens lt 3L || strlowcase(units_tokens[1]) ne 'since') then begin
    if (arg_present(error)) then begin
      error = 1L
      return, !null
    endif else message, 'invalid UNITS specification'
  endif

  if (strmid(units_tokens[2], 0, 1) eq '-') then begin
    date = strmid(units_tokens[2], 1)
    year_multiplier = -1L
  endif else begin
    date = units_tokens[2]
    year_multiplier = 1L
  endelse

  date_tokens = strsplit(date, '-', /extract, count=n_date_tokens)
  if (n_date_tokens ne 3L) then begin
    if (arg_present(error)) then begin
      error = 1L
      return, !null
    endif else message, 'invalid UNITS specification (invalid date)'
  endif
  year += year_multiplier * long(date_tokens[0])
  month += long(date_tokens[1])
  day += long(date_tokens[2])

  ; time, e.g., 15:03:30.5
  if (n_units_tokens gt 3L) then begin
    time_tokens = strsplit(units_tokens[3], ':', /extract, count=n_time_tokens)
    hour += long(time_tokens[0])
    if (n_time_tokens gt 1L) then minute += long(time_tokens[1])
    if (n_time_tokens gt 2L) then second += double(time_tokens[2])
  endif

  ; time zone, e.g., -0600, -600, -6, -6:00
  if (n_units_tokens gt 4L) then begin
    re = '^-([[:digit:]]{1,2})(:?[[:digit:]]{2})?$'
    tz_tokens = stregex(units_tokens[4], re, /subexpr, /extract)
    hour -= long(tz_tokens[1])
    minute -= long(strmid(tz_tokens[2], 0, 1) eq ':' $
                     ? strmid(tz_tokens[2], 1) $
                     : tz_tokens[2])
  endif

  switch strlowcase(units_tokens[0]) of
    's':
    'sec':
    'secs':
    'second':
    'seconds': begin
        multiplier = 1.0D / 24.0 / 60.0D / 60.0D
        break
      end
    'min':
    'mins':
    'minute':
    'minutes': begin
        multiplier = 1.0D / 24.0 / 60.0D
        break
      end
    'h':
    'hr':
    'hrs':
    'hour':
    'hours': begin
        multiplier = 1.0D / 24.0D
        break
      end
    'd':
    'day':
    'days': begin
        multiplier = 1.0D
        break
      end
    else: begin
        if (arg_present(error)) then begin
          error = 1L
          return, !null
        endif else message, 'invalid UNITS specification (invalid time unit)'
      end
  endswitch

  return, julday(month, day, year, hour, minute, second) + cf_time * multiplier
end


; main-level example program

cf_t = systime(/seconds)
julian_t = systime(/julian, /utc)
cf_units = 'seconds since 1970-01-01 00:00'

print, julian_t - mg_cf2julian(cf_t, units=cf_units), $
       format='(%"The difference between these two times should be small: %f")'

end

; docformat = 'rst'

; http://cfconventions.org/Data/cf-convetions/cf-conventions-1.7/build/cf-conventions.html#time-coordinate

;+
; Convert a time value from Julian date to `CF conventions <cfconventions.org>`.
;
; :Params:
;   jd : in, required, type=numeric
;     Julian date
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
function mg_julian2cf, jd, units=units, error=error
  compile_opt strictarr

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
        multiplier = 24.0 * 60.0D * 60.0D
        break
      end
    'min':
    'mins':
    'minute':
    'minutes': begin
        multiplier = 24.0 * 60.0D
        break
      end
    'h':
    'hr':
    'hrs':
    'hour':
    'hours': begin
        multiplier = 24.0D
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

  return, (jd - julday(month, day, year, hour, minute, second)) * multiplier
end

; docformat = 'rst'

;+
; Return a date/time structure corresponding to the `date` parsed according to
; `format`.
;
; :Returns:
;   structure of the form::
;
;     {year:0L, month:0L, day:0L, hour:0L, minute:0L, second:0.0D}
;
; :Params:
;   date : in, required, type=string
;     date string
;   format : in, required, type=string
;     format specification
;   status : out, optional, type=long
;     set to a named variable to retrieve whether the date was successfully
;     parsed, no error message is printed if this is present
;-
function mg_strptime, date, format, status=status, error_message=error_message
  compile_opt strictarr
  on_error, 2
  on_ioerror, bad_format

  status = 0L
  error_message = ''

  year = 1900L
  month = 1L
  day = 1L
  hour = 0L
  minute = 0L
  second = 0.0D

  i_date = 0L
  i_format = 0L

  token = ''

  while (i_format lt strlen(format)) do begin
    c = strmid(format, i_format, 1)
    if (c eq '%') then begin
      i_format += 1L
      code = strmid(format, i_format, 1)
      case code of
        'y': begin
            token = strmid(date, i_date, 2)
            year = long(token)
            if (year ge 70) then year += 1900L else year += 2000L
            i_date += 2L
            i_format += 1L
          end
        'Y': begin
            token = strmid(date, i_date, 4)
            year = long(token)
            i_date += 4L
            i_format += 1L
          end
        'd': begin
            token = strmid(date, i_date, 2)
            day = long(token)
            i_date += 2L
            i_format += 1L
          end
        'a': begin
            i_date += 3L
            i_format += 1L
          end
        'm': begin
            token = strmid(date, i_date, 2)
            month = long(token)
            if (month gt 12) then begin
              status = 1L
              error_message = string(month, format='(%"month %d too large for format %%m")')
              if (~arg_present(error_message)) then message, error_message
            endif
            i_date += 2L
            i_format += 1L
          end
        'b': begin
            token = strlowcase(strmid(date, i_date, 3))
            month_names = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', $
                           'jul', 'aug', 'sep', 'oct', 'nov', 'dec']
            month_index = where(token eq month_names, count)
            if (count eq 0L) then begin
              status = 1L
              error_message = string(token, format='(%"unknown month name \"%s\"")')
              if (~arg_present(error_message)) then message, error_message
            endif
            month = month_index[0] + 1L
            i_date += 3L
            i_format += 1L
          end
        'j': begin
            token = strmid(date, i_date, 3)
            doy = long(token)
            mg_doy2ymd, year, doy, year=year, month=month, day=day
            i_date += 3L
            i_format += 1L
          end
        'H': begin
            token = strmid(date, i_date, 2)
            hour = long(token)
            i_date += 2L
            i_format += 1L
          end
        'I': begin
            token = strmid(date, i_date, 2)
            hour = long(token)
            if (hour gt 12) then begin
              status = 1L
              error_message = string(hour, format='(%"hour %d too large for format %%I")')
              if (~arg_present(error_message)) then message, error_message
            endif
            i_date += 2L
            i_format += 1L
          end
        'M': begin
            token = strmid(date, i_date, 2)
            minute = long(token)
            if (minute ge 60) then begin
              status = 1L
              error_message = string(minute, format='(%"minute %d too large for format %%M")')
              if (~arg_present(error_message)) then message, error_message
            endif
            i_date += 2L
            i_format += 1L
          end
        'S': begin
            token = strmid(date, i_date, 2)
            second = long(token)
            if (second ge 60) then begin
              status = 1L
              error_message = string(second, format='(%"second %d too large for format %%S")')
              if (~arg_present(error_message)) then message, error_message
            endif
            i_date += 2L
            i_format += 1L
          end
        'f': begin
            token = strmid(date, i_date, 6)
            second += long(token) / 1.0d6
            i_date += 6L
            i_format += 1L
          end
        'p': begin
            token = strmid(date, i_date, 2)
            case strlowcase(token) of
              'am': if (hour eq 12) then hour = 0L
              'pm': if (hour lt 13) then hour += 12L
              else: begin
                  status = 1L
                  error_message = string(token, format='(%"unknown AM/PM indicator \"%s\"")')
                  if (~arg_present(error_message)) then message, error_message
                end
            endcase
            i_date += 2L
            i_format += 1L
          end
        else: begin
            status = 1L
            error_message = string(code, format='(%"unknown format code \"%%%s\"")')
            if (~arg_present(error_message)) then message, error_message
          end
      endcase
    endif else begin
      if (c ne strmid(date, i_date, 1)) then begin
        status = 1L
        error_message = string(date, format, i_date, $
                               format='(%"date \"%s\" does not match format \"%s\" at position %d")')
        if (~arg_present(error_message)) then message, error_message
      endif
      i_date += 1L
      i_format += 1L
    endelse
  endwhile

  return, {year: year, month: month, day: day, hour: hour, minute: minute, second: second}

  bad_format:
  status = 1L
  error_message = string(token, format='(%"bad format in token \"%s\"")')
  if (~arg_present(error_message)) then message, error_message
end


; main-level example program

d = mg_date(mg_strptime('2018-06-05T01:18:00', '%Y-%m-%dT%H:%M:%S'))
help, d

end

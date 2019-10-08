; docformat = 'rst'

;+
; Normalize a date/time string, i.e., correct string if minutes or seconds are
; equal to 60, hours is 24, etc.
;
; :Params:
;   dt : in, required, type=string
;     date/time string in the form "YYYY-MM-DDTHH:MM:SS"
;-
function mg_normalize_datetime, dt
  compile_opt strictarr

  tokens = long(strsplit(dt, '-:T', /extract, count=n_tokens))

  if (tokens[5] ge 60L) then begin
    tokens[5] -= 60L
    tokens[4] += 1L
  endif

  if (tokens[4] ge 60L) then begin
    tokens[4] -= 60L
    tokens[3] += 1L
  endif

  if (tokens[3] ge 23) then begin
    tokens[3] -= 24L
    tokens[2] += 1L
  endif

  days_in_month = mg_month_days(tokens[0], tokens[1])
  if (tokens[2] gt days_in_month) then begin
    tokens[2] -= days_in_month
    tokens[1] += 1L
  endif

  if (tokens[1] gt 12L) then begin
    tokens[1] -= 12L
    tokens[0] += 1L
  endif

  return, string(tokens, format='(%"%04d-%02d-%02dT%02d:%02d:%02d")')
end


; main-level example

dt = '2017-09-10T19:28:60'
print, dt, mg_normalize_datetime(dt), format='(%"%s -> %s")'

end

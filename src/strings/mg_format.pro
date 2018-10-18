; docformat = 'rst'

;+
; Construct a C-style format string. Allows "*" for width or precision in the
; format string.
;
; :Examples:
;   For example::
;
;     IDL> format = mg_format('Temp: %*.*f', [0, 1])
;     IDL> print, format
;     (%"Temp: %0.1f,")
;     IDL> print, 25.57, format=format
;     Temp: 25.6
;
; :Returns:
;   string
;
; :Params:
;   format : in, required, type=string
;     C-style format string
;   args : in, optional, type=lonarr
;     optional widths and precisions
;
; :Keywords:
;   simple : in, optional, type=boolean
;     set to return simple C format string, i.e., without the `%""`
;-
function mg_format, format, args, simple=simple
  compile_opt strictarr
  on_error, 2

  re = '([^%]|^)%([-+])?([[:digit:]\*]+\.)?([[:digit:]\*]+)([[:alpha:]])'

  _format = format
  result = ''

  a = 0L
  while (a le n_elements(args) - 1L) do begin
    per_locs = stregex(_format, '%%', length=per_len)

    locs = stregex(_format, re, length=len, /subexpr)
    if ((per_locs[0] ge 0L) && ((locs[0] lt 0L) || (per_locs[0] lt locs[0]))) then begin
      result += strmid(_format, 0, per_locs[0] + per_len[0])
      if (strlen(_format) gt (per_locs[0] + per_len[0] + 1)) then begin
        _format = strmid(_format, per_locs[0] + per_len[0])
      endif else _format = ''
      continue
    endif

    if (locs[0] eq -1L) then begin
      message, 'invalid format: too many arguments'
    endif

    result += strmid(_format, 0, locs[1] + len[1]) + '%'

    ; handle +-
    if (locs[2] ne -1) then begin
      result += strmid(_format, locs[2], len[2])
    endif

    ; handle width
    if (locs[3] ne -1) then begin
      width = strmid(_format, locs[3], len[3])
      if (width eq '*.') then begin
        result += string(args[a], format='(%"%d.")')
        a += 1L
      endif else begin
        result += width
      endelse
    endif

    ; handle precision
    if (locs[4] ne -1L) then begin
      precision = strmid(_format, locs[4], len[4])
      if (precision eq '*') then begin
        if (a ge n_elements(args)) then message, 'invalid format: not enough arguments'

        result += string(args[a], format='(%"%d")')
        a += 1L
      endif else begin
        result += precision
      endelse
    endif

    ; add specifier
    result += strmid(_format, locs[5], len[5])

    ; remove used part of _format
    if (strlen(_format) gt (locs[0] + len[0] + 1)) then begin
      _format = strmid(_format, locs[0] + len[0])
    endif else _format = ''
  endwhile

  locs = stregex(_format, re, length=len, /subexpr)
  if ((locs[3] ne -1L) && (strmid(_format, locs[3], len[3]) eq '*.')) then begin
    message, 'invalid format: not enough arguments'
  endif
  if ((locs[4] ne -1L) && (strmid(_format, locs[4], len[4]) eq '*')) then begin
    message, 'invalid format: not enough arguments'
  endif

  result += _format
  if (~keyword_set(simple)) then begin
    result = '(%"' + result + '")'   ; add IDL's C-style indicators
  endif

  return, result
end


; main-level example

format = 'Name: %s'
output_format = mg_format(format)
print, format, output_format, $
       format='(%"format: ''%s'' -> %s")'

format = 'Weight: %4.*f, age: %*d'
args = [1, 4]
output_format = mg_format(format, args)
print, format, strjoin(strtrim(args, 2), ', '), output_format, $
       format='(%"format: ''%s'' and args: [%s] -> %s")'

format = 'Weight: %*.*f'
args = [1, 4]
output_format = mg_format(format, args)
print, format, strjoin(strtrim(args, 2), ', '), output_format, $
       format='(%"format: ''%s'' and args: [%s] -> %s")'

format = 'Weight: %*.1f, age: %*d, and height: %0.*f'
args = [0, 3, 1]
output_format = mg_format(format, args)
print, format, strjoin(strtrim(args, 2), ', '), output_format, $
       format='(%"format: ''%s'' and args: [%s] -> %s")'
print, 190.0, 46, 6.0, format=output_format

end

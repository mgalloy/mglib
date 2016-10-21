; docformat = 'rst'

;+
; Maintain a one-line status line on a VT100-compatible terminal (Unix only).
; Compatible with the interface of Craig Markwardt's `STATUSLINE` routine.
;
; Programs that run for extended periods of time can inform the user of the
; status of the computation by updating their status on a single line instead of
; cluttering the console with output from multiple `PRINT` statements.
;
; `MG_STATUSLINE` interacts directly with the Unix terminal device, sending
; VT100-compatible cursor commands. As a side effect it opens the terminal
; device `/dev/tty` and allocates a logical unit number. To close the file unit,
; call::
;
;   IDL> mg_statusline, /close
;
; Procedures that finish their computation, or wish to make normal output to the
; console, should first clear the terminal line with::
;
;   IDL> mg_statusline, /clear
;
; If using `LENGTH` to output status messages, set the same length on the clear.
; This will ensure that the console is uncluttered before printing.
;
; By default, `MG_STATUSLINE` enables output for terminal types vt100, vtnnn,
; xterm, dec, or ansi. No output appears on other terminals. You can enable
; it explicitly by calling::
;
;   IDL> mg_statusline, /enable
;
; and disable it by calling::
;
;   IDL> mg_statusline, /disable
;
; But if `/dev/tty` can't be opened, no output will appear even if explicitly
; enabled.
;
; :Examples:
;   Try the example main-level program at the end of this file. Run it with::
;
;     IDL> .run mg_statusline
;
;   The example does the following::
;
;     for i = 0, 10 do begin
;       mg_statusline, string(i, format='(%"item: %d")'), /right, length=100
;       wait, 0.2
;     endfor
;
;     mg_statusline, /clear, length=100
;
;     print, 'This is the next line of normal output.'
;
; :Params:
;   str : in, required, type=string
;     a string to be placed on the current line
;   column : in, optional, type=integer, default=0
;     the starting column number, beginning with zero
;
; :Keywords:
;   length : in, optional, type=integer, default=strlen(str)
;     the record length; strings longer than this length will be truncated
;   clear : in, optional, type=boolean
;     if set, clear the current line to the end; control returns immediately,
;     i.e., no output is made
;   left : in, optional, type=boolean
;     set to left justify the output; the default unless `RIGHT` is set
;   right : in, optional, type=boolean
;     If set, then right jusfity the string within the record. If the string is
;     longer than the record length, then the rightmost portion of the string is
;     printed.
;   quiet : in, optional, type=boolean
;     if set, then no output is made (for this call only)
;   close : in, optional, type=boolean
;     If set, instruct `MG_STATUSLINE` to close the terminal device logical unit
;     number. Users should perform this operation when the computation has
;     finished so that the terminal device is not left dangling open. If, at a
;     later time, `MG_STATUSLINE` is called again, the terminal device will be
;     re-opened.
;   enable : in, optional, type=boolean
;     set to explicitly enable status line
;   disable : in, optional, type=boolean
;     set to explicitly disable status line
;   nocr : in, optional, type=boolean
;     If set, no carriage return operation is performed after output. This also
;     has the side effect that in subsequent calls, column "0" will not cause
;     the cursor to move. The default is for the cursor to return to column 0
;     after each output.
;   error : out, optional, type=long
;     set to a named variable to retrieve the error status; 0 for success, other
;     values indicate errors
;-
pro mg_statusline, str, column, length=length, clear=clear, $
                   left=left, right=right, quiet=quiet, close=close, $
                   enable=enable, disable=disable, nocr=nocr, error=error
  compile_opt strictarr
  on_error, 2
  common mg_statusline_common, statusline_enabled, statusline_unit

  error = 0L
  _length = n_elements(length) eq 0L $
              ? (n_elements(str) eq 0L ? 80L : strlen(str)) $
              : length
  _column = n_elements(column) eq 0L ? 0L : (column > 0L)

  statusline_enabled = 0B
  termtype = getenv('TERM')
  switch 1 of
    termtype eq 'screen':
    strmid(termtype, 0, 2) eq 'vt':
    strmid(termtype, 0, 5) eq 'xterm':
    strmid(termtype, 0, 3) eq 'dec':
    termtype eq 'ansi': begin
        statusline_enabled = 1B
        break
      end
    else:
  endswitch

  if (keyword_set(enable)) then begin
    statusline_enabled = 1B
    return
  endif

  if (keyword_set(disable)) then begin
    statusline_enabled = 0B
    return
  endif

  if (n_elements(str) eq 0 && ~keyword_set(clear)) then begin
    error = 1L
    message, 'str argument required'
  endif

  if (keyword_set(quiet) || statusline_enabled eq 0L) then return

  do_open = 0B
  if (n_elements(statusline_unit) eq 0L) then do_open = 1B
  if (n_elements(statusline_unit) gt 0L) then begin
    if (statusline_unit[0] lt 0L) then do_open = 1B

    ; if the user closes the file behind our back, e.g., CLOSE, /ALL
    if (statusline_unit[0] ge 0L) then begin
      fs = fstat(statusline_unit[0])
      if (fs.open eq 0L) then do_open = 1B
    endif
  endif

  if (do_open) then begin
    statusline_unit = -1L
    if (keyword_set(close)) then return
    openw, unit, '/dev/tty', /get_lun, error=open_error
    if (open_error ne 0) then begin
      error = 2L
      return
    endif
    statusline_unit = unit
  endif

  if (keyword_set(close) && n_elements(statusline_unit) ge 1L) then begin
    if (statusline_unit[0] lt 0) then return
    free_lun, statusline_unit[0]
    statusline_unit = -1L
    return
  endif

  ; ASCII values
  cr = string(13b)
  esc = string(27b)

  if (keyword_set(clear)) then begin
    clear_format = string(_length, format='(%"(A%d, A, $)")')
    outstring = string(' ', cr, format=clear_format)

    ; prevent errors from crashing program
    catch, catcherr
    if (catcherr eq 0L) then begin
      writeu, statusline_unit, outstring
    endif else error = 3L

    return
  endif

  ; construct new output string
  _str = str
  slen = strlen(str)
  if (slen gt _length) then begin
    if (keyword_set(right)) then begin
      _str = strmid(_str, slen - _length, _length)
    endif else begin
      _str = strmid(_str, 0, _length)
    endelse
  endif else begin
    if (keyword_set(right)) then begin
      blanks = string(bytarr(_length - slen) + (byte(' '))[0])
      _str = blanks + _str
    endif
  endelse

  outstring = ''
  if (_column gt 0) then outstring += esc + '[' + strtrim(_column, 2) + 'C'
  outstring += _str 
  if (~keyword_set(nocr)) then outstring += cr

  ; prevent errors from crashing program
  catch, catcherr
  if (catcherr eq 0L) then begin
    writeu, statusline_unit, outstring
  endif else error = 4L
end


; main-level example program

for i = 0, 10 do begin
  mg_statusline, string(i, format='(%"item: %d")'), /right, length=90
  wait, 0.2
endfor

mg_statusline, /clear, length=90

print, 'This is the next line of normal output.'

end


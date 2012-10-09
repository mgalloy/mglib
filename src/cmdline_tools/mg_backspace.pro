; docformat = 'rst'

;+
; Backspaces a `nchars` characters. Backspacing beyond the beginning of a line
; will have no effect.
;
; If trying to erase previous content, make sure to print the previous content
; using the `$` format code which indicates to not move to a new line.
;
; Note that this routine will not work in terminals that don't understand
; ANSI escape codes, i.e., the Workbench command line.
;
; :Examples:
;    Try the main-level example program at the end of this file::
;
;       IDL> .run mg_backspace
;       100%
;
; :Params:
;    nchars : in, optional, type=long, default=1L
;       number of characters to backspace
;-
pro mg_backspace, nchars
  compile_opt strictarr

  _nchars = n_elements(nchars) eq 0L ? 1L : nchars

  esc = string(27B)
  print, esc + '[' + strtrim(_nchars, 2) + 'D' + esc + '[K', format='(A, $)'
end


; main-level example program

for i = 0, 100 do begin
  mg_backspace, 4
  print, i, format='(I3, "%", $)'
  wait, 0.1
endfor

print

end

; docformat = 'rst'

;+
; Create a temporary filename from a C-style format.
;
; :Examples:
;    Try the main-level example program at the end of this file::
; 
;       IDL> .run mg_temp_filename
; 
; :Returns:
;    string
;
; :Params:
;    format : in, required, type=string
;       C-style format string to specify the base filename; should include 
;       one %s to be filled in by a time stamp
;
; :Keywords:
;    length : in, optional, type=integer, default=15L
;       number of characters in the time stamp, will be increased to fit the
;       n_decimals specified
;    n_decimals : in, optional, type=integer, default=3L
;       number of decimal places to include in the time stamp, default is 3 
;       i.e. milliseconds
;-
function mg_temp_filename, format, length=length, n_decimals=ndecimals
  compile_opt strictarr
  
  _length = n_elements(length) eq 0L ? 15L : length
  _ndecimals = n_elements(ndecimals) eq 0L ? 3L : ndecimals
  
  t = 10.D ^ _ndecimals * systime(/seconds)
  _length >= fix(alog10(t)) + 1L
  
  _length = strtrim(_length, 2L)
  
  timestamp = string(t, format='(I0' + _length + ')')
  return, filepath(string(timestamp, format='(%"' + format + '")'), /tmp)
end


; main-level example

print, mg_temp_filename('mg_temp_filename-%s.txt')

end

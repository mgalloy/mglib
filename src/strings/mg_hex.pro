; docformat = 'rst'

;+
; Returns the hexadecimal representation of a integer value as a string.
;
; :Examples:
;   For example::
;
;     IDL> help, mg_hex(1000)
;     <Expression>    STRING    = '3E8'
;     IDL> help, mg_hex(1000, width=4)
;     <Expression>    STRING    = '03E8'
;
; :Returns:
;   string
;
; :Params:
;   value : in, required, type=integer type
;     value to display
;
; :Keywords:
;   width : in, optional, type=integer
;     width of result in string characters; if the width is specified, but
;     shorter than necessary to display the input, the result will be a
;     `width`-long string of asterisks, i.e., "****"
;-
function mg_hex, value, width=width
  compile_opt strictarr

  format = n_elements(width) gt 0L $
             ? string(width, width, format='(%"(Z%d.%d)")') $
             : '(Z0.0)'
  return, string(value, format=format)
end
  
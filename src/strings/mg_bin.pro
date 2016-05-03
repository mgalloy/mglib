; docformat = 'rst'

;+
; Returns the binary representation of a integer value as a string.
;
; :Examples:
;   For example::
;
;     IDL> help, mg_bin(1000)
;     <Expression>    STRING    = '1111101000'
;     IDL> help, mg_bin(1000, width=16)
;     <Expression>    STRING    = '0000001111101000'
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
function mg_bin, value, width=width
  compile_opt strictarr

  format = n_elements(width) gt 0L $
             ? string(width, width, format='(%"(B%d.%d)")') $
             : '(B0.0)'
  return, string(value, format=format)
end
  
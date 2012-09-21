; docformat = 'rst'

;+
; Convenience routine to convert a 1-element string to a character value.
;
; :Returns:
;    byte value
;
; :Params:
;    s : in, required, type=string
;       1-element string to convert to a character value
;-
function mg_char, s
  compile_opt strictarr

  return, (byte(s))[0]
end

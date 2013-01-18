; docformat = 'rst'

;+
; Decode a string in Base64, performs the inverse operation as
; `MG_BASE64ENCODE`.
;
; :Examples:
;    Try::
;
;       IDL> s = 'username: password'
;       IDL> print, s, format='(%"Original string: \"%s\"")'
;       Original string: "username: password"
;       IDL> enc = mg_base64encode(s)
;       IDL> print, enc, format='(%"Encoded string: \"%s\"")'
;       Encoded string: "dXNlcm5hbWU6IHBhc3N3b3Jk"
;       IDL> dec = mg_base64decode(enc)
;       IDL> print, dec, format='(%"Decoded string: \"%s\"")'
;       Decoded string: "username: password"
;
; :Returns:
;    string
;
; :Params:
;    s : in, required, type=string
;       string to decode
;-
function mg_base64decode, s
  compile_opt strictarr

  _translate = bytarr(123)
  _translate[bindgen(26) + 65B] = bindgen(26)       ; A-Z
  _translate[bindgen(26) + 97B] = bindgen(26) + 26  ; a-z
  _translate[bindgen(10) + 48B] = bindgen(10) + 52  ; a-z
  _translate[43] = 62B                              ; +
  _translate[47] = 63B                              ; /

  ns = strlen(s)
  ind = where(byte(strmid(s, 3, /reverse_offset)) eq (byte('='))[0], npadding)
  ind = _translate[byte(strmid(s, 0, ns - npadding))]

  b = bytarr(3 * (ns - npadding) / 4)
  reads, string(ind, format='(' + strtrim(n_elements(ind), 2) + 'B06)'), b, $
         format='(' + strtrim(3 * (ns - npadding) / 4, 2) + 'B8)'

  return, string(b)
end


; main-level example program

s = 'username: password'
print, s, format='(%"Original string: \"%s\"")'

enc = mg_base64encode(s)
print, enc, format='(%"Encoded string: \"%s\"")'

dec = mg_base64decode(enc)
print, dec, format='(%"Decoded string: \"%s\"")'

end

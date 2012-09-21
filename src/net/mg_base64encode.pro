; docformat = 'rst'

;+
; Encode a string using Base64, performs the inverse operation as 
; `MG_BASE64DECODE`.
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
;       string to encode
;-
function mg_base64encode, s
  compile_opt strictarr
  
  _translate = [bindgen(26) + (byte('A'))[0], $   ; A-Z
                bindgen(26) + (byte('a'))[0], $   ; a-z
                bindgen(10) + (byte('0'))[0], $   ; 0-9
                (byte('+'))[0], $                 ; +
                (byte('/'))[0]]                   ; /
  
  npadding = 3 - strlen(s) mod 3
  npadding = npadding eq 3L ? 0L : npadding

  b = npadding eq 0L ? byte(s) : [byte(s), bytarr(npadding)]
    
  n = n_elements(b)
  ind = bytarr(4 * n / 3)

  reads, string(b, format='(' + strtrim(n, 2) + 'B08)'), ind, $
         format='(' + strtrim(4 * n / 3, 2) + 'B6)' 

  return, string(_translate[ind[0:n_elements(ind) - npadding - 1L]]) $
            + (npadding gt 0L ? strjoin(strarr(npadding) + '=') : '')
end


; main-level example program

s = 'Man is distinguished, not only by his reason, but by this singular ' $
      + 'passion from other animals, which is a lust of the mind, that by ' $
      + 'a perseverance of delight in the continued and indefatigable ' $
      + 'generation of knowledge, exceeds the short vehemence of any carnal ' $
      + 'pleasure.'
print, mg_base64encode(s)

end

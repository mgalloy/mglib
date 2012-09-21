; docformat = 'rst'

;+
; Hash the input string using MD5.
;
; :Examples:
;    For example, try::
; 
;       IDL> print, mg_md5('http://michaelgalloy.com')
;       d17d014489c31038dee48b6d5132297f
;
; :Returns:
;    string
;
; :Params:
;    s : in, required, type=string
;       string to hash
;
; :Keywords:
;    hexidecimal : in, optional, type=boolean
;       return result hash in hexadecimal string
;-
function mg_md5, s, hexidecimal=hexidecimal
  compile_opt strictarr
  
  ; convert string to ASCII representation
  _s = byte(s)
  ns = strlen(_s)
  
  ; append padding bytes
  npad = (56L - ns) mod 64L
  npad = npad lt 0 ? (64L + npad) : npad
  npad = npad eq 0 ? 64L : npad
  
  pad = bytarr(npad)
  pad[0] = '10000000'b
  
  _s = ns eq 0L ? pad : [_s, pad]
  _s = ulong(_s, 0, n_elements(_s) / 4)
  
  ; appending long of original string
  _s = [_s, long(ulong64(ns), 0, 2)]
  
  ; initialize MD buffer
  a = '67452301'xu
  b = 'efcdab89'xu
  c = '98badcfe'xu
  d = '10325476'xu
  
  ; process message
  ; TODO: implement this processing (http://www.freesoft.org/CIE/RFC/1321/7.htm)
  
  return, string([a, b, c, d], format='(4Z0)')
end


; main-level example

print, mg_md5('http://michaelgalloy.com')
;d17d014489c31038dee48b6d5132297f

end

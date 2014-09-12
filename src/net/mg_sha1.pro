; docformat = 'rst'

;+
; :History:
;   derived from John Correira (correira@ceepeeeye.com) post on idl-pvwave
;   newsgroup
;-


;+
; First round helper routine.
;
; :Private:
;
; :Returns:
;   unsigned long
;
; :Params:
;   x : in, required, type=unsigned long
;     first arg
;   y : in, required, type=unsigned long
;     second arg
;   z : in, required, type=unsigned long
;     third arg
;-
function mg_sha_helper1, x, y, z
  return, (x and y) or ((not x) and z)
end


;+
; Second round helper routine.
;
; :Private:
;
; :Returns:
;   unsigned long
;
; :Params:
;   x : in, required, type=unsigned long
;     first arg
;   y : in, required, type=unsigned long
;     second arg
;   z : in, required, type=unsigned long
;     third arg
;-
function mg_sha_helper2, x, y, z
  return, x xor y xor z
end


;+
; Third round helper routine.
;
; :Private:
;
; :Returns:
;   unsigned long
;
; :Params:
;   x : in, required, type=unsigned long
;     first arg
;   y : in, required, type=unsigned long
;     second arg
;   z : in, required, type=unsigned long
;     third arg
;-
function mg_sha_helper3, x, y, z
  return, (x and y) or (x and z) or (y and z)
end



;+
; Find the SHA1 hash of the input.
;
; :Returns:
;   string
;
; :Params:
;   input : in, required, type=string
;
; :Keywords:
;   string : in, optional, type=boolean
;     set to specify input is to be treated as a string (even if it is a valid
;     filename)
;   file : in, optional, type=boolean
;     set to specify input is a filename to a file to use as input
;-
function mg_sha1, input, string=string, file=file
  compile_opt strictarr
  on_error, 2

  is_file = (file_test(input) || keyword_set(file)) && ~keyword_set(string)

  if (is_file) then begin
    is_empty = file_test(input, /zero_length)
    is_readable = file_test(input, /read)
    if (~is_readable) then begin
      message, 'file unreadable'
    endif

    msg = is_empty ? byte('') : read_binary(input)
  endif else begin
    msg = byte(input)
  endelse

  mlen = msg[0] eq 0b ? 0ULL : 8ULL*N_ELEMENTS(msg)
  msg = msg[0] eq 0 ? 128b : [TEMPORARY(msg),128b]
  while (8*N_ELEMENTS(msg) mod 512) ne 448 do $
    msg = [TEMPORARY(msg),0b]
  msg = [TEMPORARY(msg),reverse(byte(mlen,0,8))]
  msg = ulong(msg)

  h0 = '67452301'xul
  h1 = 'EFCDAB89'xul
  h2 = '98BADCFE'xul
  h3 = '10325476'xul
  h4 = 'C3D2E1F0'xul

  w0 = ulonarr(80)

  for chunk_index = 0L, n_elements(msg) - 1L, 64L do begin
    m = msg[chunk_index:chunk_index + 63L]
    w = w0
    for i = 0L, 15L do begin
      w[i] = total(m[i * 4L:i * 4L + 3L] * [16777216UL, 65536UL, 256UL, 1UL], $
                  /preserve_type)
    endfor
    temp = w
    for i = 16L, 79L do begin
      temp = w[i - 3L] xor w[i - 8L] xor w[i - 14L] xor w[i - 16L]
      w[i] = (temp * 2UL) OR (temp / 2147483648UL)
    endfor

    a = h0
    b = h1
    c = h2
    d = h3
    e = h4

    for i = 0L, 19L do begin
      temp = ((a * 32UL) or (a / 134217728UL)) + mg_sha_helper1(b, c, d) $
               + e + 1518500249ULL + w[i]
      e = d
      d = c
      c = (b * 1073741824UL) or (b / 4UL)
      b = a
      a = ulong(temp)
    endfor

    for i = 20L, 39L do begin
      temp = ((a * 32UL) or (a / 134217728UL)) + mg_sha_helper2(b, c, d) $
               + e + 1859775393ull + w[i]
      e = d
      d = c
      c = (b * 1073741824UL) or (b / 4UL)
      b = a
      a = ulong(temp)
    endfor

    for i = 40L, 59L do begin
      temp = ((a * 32UL) or (a / 134217728UL)) + mg_sha_helper3(b, c, d) $
               + e + 2400959708ULL + w[i]
      e = d
      d = c
      c = (b * 1073741824UL) or (b / 4UL)
      b = a
      a = ulong(temp)
    endfor
    for i=60, 79 do begin
      temp = ((a * 32UL) or (a / 134217728UL)) + mg_sha_helper2(b, c, d) $
               + e + 3395469782ULL + w[i]
      e = d
      d = c
      c = (b * 1073741824UL) or (b / 4UL)
      b = a
      a = ulong(temp)
    endfor

    h0 += a
    h1 += b
    h2 += c
    h3 += d
    h4 += e
  endfor

  return, string(h0, h1, h2, h3, h4, format='(5(z08))')
end
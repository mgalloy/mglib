; docformat = 'rst'

;+
; Object that converts strings to values that are safe to use in URLs.
;
; :Examples:
;   Try the main-level example program at the end of this file::
;
;     IDL> .run mgneturlquoter__define
;
; :Properties:
;   safe : type=string
;     string of characters that don't need to be replaced, i.e., they are
;     safe to use in an URL; the default is `/`
;-

;+
; Convert special characters in `str` using the `%xx` escape sequence. The
; alphaumeric characters, `_`, `.`, and `-` are always safe to use.
;
; :Examples:
;   For example::
;
;     IDL> print, quoter->quote('/Boulder, CO.html')
;     /Boulder%2C%20CO.html
;
; :Returns:
;   string
;
; :Params:
;   str : in, required, type=string
;     string to convert
;-
function mgneturlquoter::quote, str
  compile_opt strictarr

  b = byte(str)
  b = reform(b, 1, n_elements(b), /overwrite)

  bresult = self.table[1:3, b]

  return, strjoin(string(bresult))
end


;+
; Similar to the `quote` method, but converts spaces to `+` signs instead of
; the normal `%xx` notation.
;
; :Examples:
;   For example::
;
;     IDL> print, quoter->quotePlus('/Boulder, CO.html')
;     /Boulder%2C+CO.html
;
; :Returns:
;   string
;
; :Params:
;   str : in, required, type=string
;     string to convert
;-
function mgneturlquoter::quotePlus, str
  compile_opt strictarr

  space = byte(' ')
  saved_space = self.table[1:3, space]
  self.table[1:3, space] = [byte('+'), 0B, 0B]

  result = self->quote(str)

  self.table[1:3, space] = saved_space

  return, result
end


;+
; Replace `%xx` escape sequences by their single-character equivalent.
;
; :Examples:
;   For example::
;
;     IDL> print, quoter->unquote('/Boulder%2C%20CO.html')
;     /Boulder, CO.html
;
; :Returns:
;   string
;
; :Params:
;   str : in, required, type=string
;     string to convert
;-
function mgneturlquoter::unquote, str
  compile_opt strictarr

  tokens = strsplit(str, '%', count=ntokens, /extract, /preserve_null)
  if (ntokens gt 1) then begin
    chars = bytarr(ntokens - 1L)
    reads, strmid(tokens[1:*], 0, 2), chars, format='(Z02)'
    chars = string(reform(chars, 1, ntokens - 1))
    return, tokens[0] $
              + strjoin(reform(transpose([[chars], [strmid(tokens[1:*], 2)]]), $
                               2L * (ntokens - 1L)))
  endif else return, str
end


;+
; Replace `%xx` escape sequences by their single-character equivalent and
; replace `+` sign with space.
;
; :Examples:
;   For example::
;
;     IDL> print, quoter->unquotePlus('/Boulder%2C+CO.html')
;     /Boulder, CO.html
;
; :Returns:
;   string
;
; :Params:
;   str : in, required, type=string
;     string to convert
;-
function mgneturlquoter::unquotePlus, str
  compile_opt strictarr

  b = byte(str)
  ind = where(b eq (byte('+'))[0], count)
  if (count gt 0L) then begin
    b[ind] = byte(' ')
  endif

  return, self->unquote(string(b))
end


;= lifecycle methods

;+
; Create a quoter object.
;
; :Returns:
;   1 for success, 0 for failure
;-
function mgneturlquoter::init, safe=safe
  compile_opt strictarr

  self.table[0, *] = bindgen(256)
  self.table[1, *] = byte('%')
  self.table[2:3, *] = byte(string(fix(self.table[0, *]), format='(Z02)'))

  _safe = n_elements(safe) eq 0L ? '/' : safe
  self.safe = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVQXYZ0123456789_.-' + _safe

  for c = 0L, strlen(self.safe) - 1L do begin
    char = strmid(self.safe, c, 1)
    self.table[1:3, byte(char)] = [byte(char), 0B, 0B]
  endfor

  return, 1
end


;+
; Define instance variables.
;-
pro mgneturlquoter__define
  compile_opt strictarr

  define = { MGnetUrlQuoter, $
             safe: '', $
             table: bytarr(4, 256) $
           }
end


; main-level example program

s = 'Mike Galloy_1/'

quoter = obj_new('MGnetUrlQuoter')

print, s, format='(%"String is = \"%s\"")'

quotedString = quoter->quote(s)
print, quotedString, format='(%"Quoted string is = \"%s\"")'

unquotedString = quoter->unquote(quotedString)
print, unquotedString, format='(%"Unquoted string is = \"%s\"")'

quotedPlusString = quoter->quotePlus(s)
print, quotedPlusString, format='(%"Quoted plus string is = \"%s\"")'

unquotedPlusString = quoter->unquotePlus(quotedPlusString)
print, unquotedPlusString, format='(%"Unquoted plus string is = \"%s\"")'

obj_destroy, quoter

end

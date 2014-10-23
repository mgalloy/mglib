; docformat = 'rst'

;+
; Handle string replacment with regular expressions.
;
; :Examples:
;   The following example demonstrates basic operations of `MG_STREPLACE`,
;   simply replacing "was" with "was not" in the expression "Mike was here"::
;
;     IDL> print, mg_streplace('Mike was here', 'was', 'was not')
;     Mike was not here
;
;   Meta-variables $1, $2, etc. represent matched values in parentheses. This
;   swaps the first two words in the string::
;
;     IDL> print, mg_streplace('Mike was here', '([^ ]*) ([^ ]*)', '$2 $1')
;     was Mike here
;
;   Capitalize the name following "Mike". Here, EVALUATE and GLOBAL replace
;   all patching expressions with an evaluated expression::
;
;     IDL> s = 'MikeGeorgeHenryMikeBill'
;     IDL> re = 'Mike([A-Z][a-z]*)'
;     IDL> expr = '"Mike" + strupcase($1)'
;     IDL> print, mg_streplace(s, re, expr, /evaluate, /global)
;     MikeGEORGEHenryMikeBILL
;
;   Another evaluated expression::
;
;     IDL> re = 'Mike([0-9]+)'
;     IDL> expr = 'fix($1) * 2'
;     IDL> help, mg_streplace('Mike5', re, expr, /evaluate)
;     <Expression>    LONG      =           10
;
;   Here's an example to put grouping commas into a long integer value::
;
;     IDL> str = '1874382735872851'
;     IDL> re = '^[+-]?([[:digit:]]+)([[:digit:]]{3})'
;     IDL> for i = 0, strlen(str) / 3 - 1 do $
;     IDL>   str = mg_streplace(str, re, '$1,$2', /global)
;     IDL> print, str
;     1,874,382,735,872,851
;
; :Returns:
;   string
;
; :Params:
;   str : in, required, type=string
;     a string to search for expressions and replace them
;   pattern : in, required, type=string
;     a regular expression possibly using subexpressions; see IDL's online
;     help for `STREGEX` for help on regular expressions
;   replacement : in, required, type=string
;     the string to replace matches of the "pattern"; can use $1, $2, etc.
;     to refer to subexpressions in "pattern"
;
; :Keywords:
;   evaluate : in, optional, type=boolean
;     set to evaluate the "replacement" as a IDL expression instead of just
;     a string
;   fold_case : in, optional, type=boolean
;     set to make a case insensitive match with "pattern"
;   global : in, optional, type=boolean
;     set to replace all expressions that match
;   start : out, optional, type=integral, default=0, private
;     index into string of where to start looking for the pattern
;
; :Author:
;   Michael Galloy
;-
function mg_streplace, str, pattern, replacement, $
                       evaluate=evaluate, $
                       fold_case=fold_case, $
                       global=global, $
                       start=start
  compile_opt idl2
  on_error, 2

  if (n_elements(str) ne 1) then begin
    message, 'str parameter must be a scalar string'
  endif

  if (keyword_set(global)) then begin
    ans = mg_streplace(str, pattern, replacement, start=start, $
                       fold_case=keyword_set(fold_case), $
                       evaluate=keyword_set(evaluate))

    while (start lt strlen(ans)) do begin
      temp = strmid(ans, 0, start)
      ans =  temp $
               + mg_streplace(strmid(ans, start), pattern, replacement, $
                              start=start, fold_case=keyword_set(fold_case), $
                              evaluate=keyword_set(evaluate))
      start = strlen(temp) + start
    endwhile

    return, ans
  endif

  pos = stregex(str, pattern, length=len, /subexpr, $
                fold_case=keyword_set(fold_case))

  ; pattern not found
  if (pos[0] eq -1) then begin
    start = strlen(str)
    return, str
  endif

  pre = pos[0] eq 0 ? '' : strmid(str, 0, pos[0])
  post = pos[0] + len[0] ge strlen(str) ? '' : strmid(str, pos[0] + len[0])

  ; need to put quotes around evaluated variables to be legal IDL syntax
  evalDelim = keyword_set(evaluate) ? '''' : ''

  ; $& -> pos[0], len[0]
  ; $1 -> pos[1], len[1]
  ; $2 -> pos[2], len[2]
  ; etc...
  rpos = strsplit(replacement, '$', escape='\', length=rlen)
  static_replacement = ''
  if ((n_elements(rlen) ne 1) or (rlen[0] ne 0)) then begin
    for i = 0, n_elements(rpos) - 1 do begin
      if (rpos[i] ne 0) then begin
        part = strmid(replacement, rpos[i], rlen[i])
        ppos = stregex(part, '^[0-9]+|^&', length=plen)
        if (ppos[0] eq -1) then message, 'illegal $, use \ to escape'

        match = strmid(part, ppos, plen)
        var_no = match eq '&' ? 0 : long(match)
        if (var_no ge n_elements(pos)) then begin
          message, '$' + strtrim(var_no, 2) + ' undefined'
        endif

        var = strmid(str, pos[var_no], len[var_no])
        static_replacement += evalDelim + var + evalDelim + strmid(part, ppos + plen)
      endif else begin
        if (rlen[0] eq 0) then message, 'illegal $, use \ to escape'
        static_replacement = strmid(replacement, rpos[0], rlen[0])
      endelse
    endfor
  endif

  ; call IDL if EVALUATE keyword is set
  if (keyword_set(evaluate)) then begin
    result = execute('static_replacement = ' + static_replacement)
  endif

  ret_str = pre + static_replacement + post
  start = strlen(pre) + strlen(static_replacement)

  return, ret_str
end


; main-level example programs

; The following example demonstrates basic operations of MG_STREPLACE, simply
; replacing "was" with "was not" in the expression "Mike was here":
print, mg_streplace('Mike was here', 'was', 'was not')

; Meta-variables $1, $2, etc. represent matched values in parentheses. This
; swaps the first two words in the string:
print, mg_streplace('Mike was here', '([^ ]*) ([^ ]*)', '$2 $1')

; Capitalize the name following "Mike". Here, EVALUATE and GLOBAL replace all
; patching expressions with an evaluated expression:
s = 'MikeGeorgeHenryMikeBill'
re = 'Mike([A-Z][a-z]*)'
expr = '"Mike" + strupcase($1)'
print, mg_streplace(s, re, expr, /evaluate, /global)

; Another evaluated expression:
re = 'Mike([0-9]+)'
expr = 'fix($1) * 2'
help, mg_streplace('Mike5', re, expr, /evaluate)

; Here's an example to put grouping commas into a long integer value:
str = '1874382735872851'
re = '^[+-]?([[:digit:]]+)([[:digit:]]{3})'
for i = 0, strlen(str) / 3 - 1 do $
str = mg_streplace(str, re, '$1,$2', /global)
print, str

end

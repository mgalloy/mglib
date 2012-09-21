; docformat = 'rst'

;+
; Wrapper for STREGEX which includes a FIND_ALL keyword to find all 
; occurrences within a scalar string.
;
; :Returns:
;    long/lonarr/string/strarr
;
; :Params:
;    str
;    re
; 
; :Keywords:
;    boolean
;    extract
;    length
;    subexpr
;    fold_case
;    find_all : in, optional, type=boolean
;       find all matches of the regular expression in the string instead of
;       just the first
;    url : in, optional, type=boolean
;       set to specify a regular expression which matches URLs; do not specify
;       re parameter if URL is set
;-
function mg_stregex, str, re, boolean=boolean, extract=extract, $
                     length=length, subexpr=subexpr, fold_case=foldCase, $
                     find_all=findAll, url=url
  compile_opt strictarr
  on_error, 2
  
  if (n_elements(re) gt 0L and keyword_set(url)) then begin
    message, 'regular expression specified with URL keyword set'
  endif
  
  _re = keyword_set(url) ? '[[:<:]](([[:alnum:]_-]+://?|www[.])[^[:space:]()<>]+(\([[:alnum:]_[:digit:]]+\)|([^[:punct:][:space:]]|/)))' : re
  
  if (keyword_set(findAll)) then begin
    pos = strsplit(str, _re, count=ncomplement, /regex, length=len, /preserve_null)
    _pos = pos[0L:ncomplement - 2L] + len[0L:ncomplement - 2L]
    length = pos[1L:*] - _pos
    
    return, keyword_set(extract) ? strmid(str, _pos, length) : _pos
  endif else begin
    ; you can't ask for LENGTH and set /EXTRACT
    if (arg_present(length)) then begin
      return, stregex(str, _re, boolean=boolean, extract=extract, $
                      length=length, subexpr=subexpr, fold_case=foldCase)
    endif else begin                      
      return, stregex(str, _re, boolean=boolean, extract=extract, $
                      subexpr=subexpr, fold_case=foldCase)
    endelse
  endelse
end                   
  
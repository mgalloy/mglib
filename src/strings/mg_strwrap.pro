; docformat = 'rst'

;+
; Wrap a string into a character width limit space.
;
; :Returns:
;    strarr
;
; :Params:
;    str : in, required, type=string
;       string to wrap
;
; :Keywords:
;    width : in, optional, type=long, default=mg_termcolumns()
;       width to wrap string into
;    indent : in, optional, type=long, default=0L
;       indent for each line
;    first_indent : in, optional, type=long, default=INDENT
;       indent for the first line
;-
function mg_strwrap, str, width=width, indent=indent, first_indent=firstIndent
  compile_opt strictarr

  strArray = strsplit(str, mg_newline(), count=count, /extract)
  if (count gt 1L) then begin
    result = [mg_strwrap(strArray[0], width=width, indent=indent, $
                           first_indent=firstIndent)]
    for i = 1L, count - 1L do begin
      result = [result, mg_strwrap(strArray[i], width=width, indent=indent)]
    endfor
    return, result
  endif

  _width = n_elements(width) eq 0L ? mg_termcolumns() : width

  _indent = n_elements(indent) eq 0L ? 0L : indent
  indentString = _indent eq 0L ? '' : string(bytarr(_indent) + 32B)

  _firstIndent = n_elements(firstIndent) eq 0L ? _indent : firstIndent
  firstIndentString = _firstIndent eq 0L ? '' : string(bytarr(_firstIndent) + 32B)

  tmp = str

  while (strlen(tmp) gt 0L) do begin
    _i = n_elements(result) eq 0L ? _firstIndent : _indent

    if (strlen(tmp) le _width - _i) then begin
      line = tmp
      tmp = ''
    endif else begin
      space = strpos(tmp, ' ', _width - _i, /reverse_search)
      if (space eq -1L) then begin
        space = strpos(tmp, ' ', _width - _i)
        if (space eq -1L) then space = strlen(tmp)
      endif

      line = strtrim(strmid(tmp, 0, space))
      tmp = strtrim(strmid(tmp, space + 1), 1)
    endelse

    result = n_elements(result) eq 0L $
               ? firstIndentString + line $
               : [result, indentString + line]

  endwhile

  return, result
end


; main-level example program

s1 = '@mdpiper You upgrading the go-cart??'
print, mg_strmerge(mg_strwrap(s1, width=20))
print
s2 = 'Twitterrific 2.0.1 is now approved for sale in the App Store. Important bug fixes & increases # of tweets. Coming later today.'
print, mg_strmerge(mg_strwrap(s2, width=40, indent=2, first_indent=0))
print
s3 = 'Other winners - @daviderota, @mattsa, @NetworkShadow, @adrianzzzz, @Singularity Be sure to follow @Twitterrific so we can DM your promo code'
print, mg_strmerge(mg_strwrap(s3, width=40, indent=0, first_indent=2))

end
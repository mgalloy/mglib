; docformat = 'rst'

;+
; Filters a line to make it safe for LaTeX output, i.e., escaping certain
; characters with backslashes.
;
; :Returns:
;    string
;
; :Params:
;    line : in, required, type=string
;       line to filter
;-
function mg_escape_latex, line, code=code
  compile_opt strictarr

  output = ''
  for pos = 0L, strlen(line) - 1L do begin
    ch = strmid(line, pos, 1)
    case ch of
      '_': output += keyword_set(code) ? '_' : '\_'
      '$': output += keyword_set(code) ? '$' : '\$'
      '%': output += keyword_set(code) ? '%' : '\%'
      '#': output += keyword_set(code) ? '#' : '\#'
      '&': output += keyword_set(code) ? '&' : '\&'
      '^': output += keyword_set(code) ? '^' : '\verb+^+'
      '\': output += keyword_set(code) ? '\' : '\verb+\+'
      '~': output += keyword_set(code) ? '~' : '\verb+~+'
      '{': output += keyword_set(code) ? '{' : '\{'
      '}': output += keyword_set(code) ? '}' : '\}'
      else: output += ch
     endcase
  endfor

  return, output
end

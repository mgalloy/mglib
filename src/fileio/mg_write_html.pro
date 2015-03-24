; docformat = 'rst'

;+
; Write HTML for a given IDL structure variable.
;
; :Private:
;
; :Params:
;   s : in, required, type=any
;     structure variable to convert to HTML
;
; :Keywords:
;   cellspacing : in, optional, type=long
;     cellspacing in table
;   column_classes : in, optional, type=strarr
;     class for columns of table
;   row_classes : in, optional, type=strarr
;     class for rows of table
;-
function mg_write_html_structure, s, $
                                  cellspacing=cellspacing, $
                                  column_classes=column_classes, $
                                  row_classes=row_classes
  compile_opt strictarr
  on_error, 2

  nc = n_elements(column_classes)
  nr = n_elements(row_classes)

  cs = n_elements(cellspacing) eq 0L $
         ? '' $
         : string(cellspacing, format='(%" cellspacing=\"%d\"")')
  result = string(cs, format='(%"<table%s>")')
  for r = 0L, n_elements(s) - 1L do begin
    class = nr eq 0L $
              ? '' $
              : string(row_classes[r mod nr], format='(%" class=\"%s\"")')
    result += string(class, format='(%"<tr%s>")')
    for i = 0L, n_tags(s[r]) - 1L do begin
      class = nc eq 0L $
                ? '' $
                : string(column_classes[i mod nc], format='(%" class=\"%s\"")')
      result += string(class, strtrim(s[r].(i), 2), format='(%"<td%s>%s</td>")')
    endfor
    result += '</tr>'
  endfor
  result += '</table>'

  return, result
end


;+
; Write HTML for a given IDL variable.
;
; :Returns:
;   string
;
; :Params:
;   var : in, required, type=any
;     variable to convert to HTML
;
; :Keywords:
;   cellspacing : in, optional, type=long
;     cellspacing in table
;   column_classes : in, optional, type=strarr
;     class for columns of table
;   row_classes : in, optional, type=strarr
;     class for rows of table
;-
function mg_write_html, var, $
                        cellspacing=cellspacing, $
                        column_classes=column_classes, $
                        row_classes=row_classes
  compile_opt strictarr
  on_error, 2

  case size(var, /type) of
    8: result = mg_write_html_structure(var, $
                                        cellspacing=cellspacing, $
                                        column_classes=column_classes, $
                                        row_classes=row_classes)
    else: message, 'unknown variable type'
  endcase
  return, result
end


; main-level example

data = replicate({name: '', age: 0L}, 5)
data[0].name = 'Mike'
data[0].age = 44L
data[1].name = 'Bill'
data[1].age = 47L
data[2].name = 'George'
data[2].age = 39L
data[3].name = 'Henry'
data[3].age = 50L
data[4].name = 'Frank'
data[4].age = 42L

t = mg_write_html(data, $
                  cellspacing=0, $
                  column_classes=['name', 'age'], $
                  row_classes=['odd', 'even'])
styles = 'td { margin: 0; }' $
           + ' td.name { width: 3cm; }' $
           + ' tr.odd { background-color: ddddff; }'
f = '(%"<html><head><style>%s</style></head><body>%s</body></html>")'
h = string(styles, t, format=f)
print, h

end

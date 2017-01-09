; docformat = 'rst'

;+
; 2-dimensional table of heterogeneous columns.
;
; Should have:
;   * basic read/write capability from/to CSV, Markdown, reStructured Text
;   * print to screen nicely (including using ... for too many rows, etc.)
;   * create new tables by indexing
;   * easily get underlying data
;   * allow each column to be a different type
;-


;= overload methods

function mg_table::_overloadPrint
  compile_opt strictarr

  width = 12
  dims = size(*self.data, /dimensions)
  format = '(' + strtrim(dims[0], 2) + '(%"%' + strtrim(width, 2) + '.2f"))'
  header_format = '(' + strtrim(dims[0], 2) + '(%"%' + strtrim(width, 2) + 's"))'
  line = strarr(dims[0]) + strjoin(strarr(width - 1) + '=')
  return, transpose([string(*self.column_names, format=header_format), $
                     string(line, format=header_format), $
                     string(*self.data, format=format)])
end


;= property access

pro mg_table::setProperty, column_names=column_names
  compile_opt strictarr

  if (n_elements(column_names) gt 0L) then *self.column_names = column_names
end


;= lifecycle methods

pro mg_table::cleanup
  compile_opt strictarr

  ptr_free, self.data, self.column_names
end


function mg_table::init, data, _extra=e
  compile_opt strictarr

  self.data = ptr_new(data)
  self.column_names = ptr_new(/allocate_heap)
  self->setProperty, _extra=e
  return, 1
end


pro mg_table__define
  compile_opt strictarr

  !null = {mg_table, inherits IDL_Object, $
           data: ptr_new(), $
           column_names: ptr_new()}
end


; main-level example program

df = mg_table(findgen(3, 5), column_names=['A', 'B', 'C'])
print, df
obj_destroy, df

end

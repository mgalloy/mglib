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
;
; :Properties:
;   data : type=2d array or array of structures
;     data to present
;   column_names : type=strarr
;     names of columns of the table
;-


;= helper methods

pro mg_table::_ingest, data
  compile_opt strictarr

  *self.data = data

  type = size(data, /type)
  dims = size(data, /dimensions)

  if (type eq 8L) then begin
    self.n_columns = n_tags(data)
    for c = 0L, self.n_columns - 1L do (*self.types)[c] = size(data.(c), /type)
    *self.column_names = tag_names(data)
  endif else begin
    self.n_columns = dims[0]
    *self.types = lonarr(self.n_columns) + type
    *self.column_names = !null
  endelse
end

function mg_table::_default_format, type
  compile_opt strictarr

  formats = ['', $
             '%4d', $
             '%8d', $
             '%12d', $
             '%#13.6g', $
             '%#16.8g', $
             '(%#13.6g,%#13.6g)', $
             '%s', $
             '', $
             '(%#16.8g,%#16.8g)', $
             '%12lu', $
             '%12lu', $
             '%8u', $
             '%12u', $
             '%22lld', $
             '%22llu']
  return, formats[type]
end


function mg_table::_default_format_lengths
  compile_opt strictarr

  return, [0, 4, 8, 12, 13, 16, 29, 0, 0, 35, 12, 12, 8, 12, 22, 22]
end


;= overload methods

function mg_table::_overloadPrint
  compile_opt strictarr

  format_lengths = (self->_default_format_lengths())[*self.types]
  header_format = '(%"' + strjoin('%-' + strtrim(format_lengths, 2) + 's') + '")'
  line = strarr(self.n_columns)
  for c = 0L, self.n_columns - 1L do line[c] = strjoin(strarr(format_lengths[c] - 1) + '=')
  return, transpose([string(*self.column_names, format=header_format), $
                     string(line, format=header_format)])

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

  ptr_free, self.data, self.types, self.column_names
end


function mg_table::init, data, _extra=e
  compile_opt strictarr

  self.data = ptr_new(/allocate_heap)
  self.types = ptr_new(/allocate_heap)
  self.column_names = ptr_new(/allocate_heap)

  self->_ingest, data

  self->setProperty, _extra=e
  return, 1
end


pro mg_table__define
  compile_opt strictarr

  !null = {mg_table, inherits IDL_Object, $
           data: ptr_new(), $
           n_columns: 0L, $
           types: ptr_new(), $
           column_names: ptr_new()}
end


; main-level example program

df = mg_table(findgen(3, 5), column_names=['A', 'B', 'C'])
print, df
obj_destroy, df

iris = mg_load_iris()
df = mg_table(iris.data, column_names=iris.feature_names)
print, df
obj_destroy, df

venus_filename = filepath('VenusCraterData.csv', subdir=['examples', 'data'])

end

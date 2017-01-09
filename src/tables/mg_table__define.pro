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
    self.n_rows = n_elements(data)
    *self.types = lonarr(self.n_columns)
    for c = 0L, self.n_columns - 1L do (*self.types)[c] = size(data.(c), /type)
    *self.column_names = tag_names(data)
  endif else begin
    self.n_columns = dims[0]
    self.n_rows = dims[1]
    *self.types = lonarr(self.n_columns) + type
    *self.column_names = !null
  endelse
end

function mg_table::_default_formats
  compile_opt strictarr

  return, ['', $
           'd', $
           'd', $
           'd', $
           '.6g', $
           '.8g', $
           '(%13.6g,%13.6g)', $
           's', $
           '', $
           '(%16.8g,%16.8g)', $
           'lu', $
           'lu', $
           'u', $
           'u', $
           'lld', $
           'llu']
end


function mg_table::_default_format_lengths
  compile_opt strictarr

  return, [0, 4, 8, 12, 13, 16, 29, 10, 0, 35, 12, 12, 8, 12, 22, 22]
end


;= overload methods

function mg_table::_overloadPrint
  compile_opt strictarr

  formats = (self->_default_formats())[*self.types]
  format_lengths = (self->_default_format_lengths())[*self.types]

  print_header = n_elements(*self.column_names) gt 0L
  if (print_header) then begin
    format_lengths >= (strlen(*self.column_names) + 1)
    header_format = '(%"' + strjoin('%' + strtrim(format_lengths, 2) + 's', ' ') + '")'
    line = strarr(self.n_columns)
    for c = 0L, self.n_columns - 1L do begin
      line[c] = strjoin(strarr(format_lengths[c]) + '=')
    endfor
  endif

  print_ellipses = 0B
  data_format = '(%"' + strjoin('%' + strtrim(format_lengths, 2) + formats, ' ') + '")'
  if (self.n_rows gt self.n_printable_rows) then begin
    print_ellipses = 1B
    ellipses_format = '(%"' + strjoin('%' + strtrim(format_lengths, 2) + 's', ' ') + '")'
    ellipses = strarr(self.n_columns) + '...'
    if (size(*self.data, /type) eq 8) then begin
      data_subset = (*self.data)[0:self.n_printable_rows - 1]
    endif else begin
      data_subset = (*self.data)[*, 0:self.n_printable_rows - 1]
    endelse
  endif else data_subset = *self.data
  result = strarr(2 * print_header + (self.n_rows < self.n_printable_rows) + print_ellipses)
  if (print_header) then begin
    result[0:1] = [string(*self.column_names, format=header_format), $
                   string(line, format=header_format)]
    result[2] = string(data_subset, format=data_format)
  endif else begin
    result[0] = string(data_subset, format=data_format)
  endelse
  if (print_ellipses) then result[-1] = string(ellipses, format=ellipses_format)
  return, transpose(result)
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

  self.n_printable_rows = 20

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
           n_printable_rows: 0L, $
           data: ptr_new(), $
           n_columns: 0L, $
           n_rows: 0L, $
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

data = [{price: 850000, rooms: 4, neighborhood: 'Queen Anne'}, $
        {price: 700000, rooms: 3, neighborhood: 'Fremont'}, $
        {price: 650000, rooms: 3, neighborhood: 'Wallingford'}, $
        {price: 600000, rooms: 2, neighborhood: 'Fremont'}]
df = mg_table(data, column_names=['price', 'rooms', 'neighborhood'])
print, df
obj_destroy, df

venus_filename = filepath('VenusCraterData.csv', subdir=['examples', 'data'])

end

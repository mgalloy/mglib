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

function mg_table::_subset_struct, data, cols, is_range, rows
  compile_opt strictarr

  tags = tag_names(data)
  for c = 0L, n_elements(cols) - 1L do begin
    if (c eq 0L) then begin
      s = create_struct(tags[c], data[0].(cols[c]))
    endif else begin
      s = create_struct(s, tags[c], data[0].(cols[c]))
    endelse
  endfor

  if (is_range) then begin
    _rows = rows
    if (rows[1] lt 0) then _rows[1] += self.n_rows
    n_rows = ceil((abs(_rows[1] - _rows[0]) + 1L) / abs(float(_rows[2])))
  endif else begin
    n_rows = n_elements(rows)
  endelse
  struct = replicate(s, n_rows)

  if (is_range) then begin
    for c = 0L, n_elements(cols) - 1L do begin
      struct.(c) = (data.(cols[c]))[rows[0]:rows[1]:rows[2]]
    endfor
  endif else begin
    for c = 0L, n_elements(cols) - 1L do struct.(c) = (data.cols[c])[rows]
  endelse

  return, struct
end


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

  return, ['', 'd', 'd', 'd', $
           '.6g', '.8g', '(%13.6g,%13.6g)', 's', $
           '', '(%16.8g,%16.8g)', 'lu', 'lu', $
           'u', 'u', 'lld', 'llu']
end


function mg_table::_default_format_lengths
  compile_opt strictarr

  return, [0, 4, 8, 12, 13, 16, 29, 10, 0, 35, 12, 12, 8, 12, 22, 22]
end


;= overload methods

;+
;-
function mg_table::_overloadBracketsRightSide, is_range, sub1, sub2
  compile_opt strictarr

  if (size(*self.data, /type) eq 8) then begin
    if (size(sub1, /type) eq 7) then begin
      n_matches = mg_match(*self.column_names, sub1, $
                           a_matches=column_indices, $
                           b_matches=sub_matches)
      column_indices = column_indices[sort(sub_matches)]
    endif else begin
      if (is_range[0]) then begin
        column_indices = (lindgen(self.n_columns))[sub1[0]:sub1[1]:sub1[2]]
      endif else begin
        column_indices = sub1
      endelse
    endelse
    new_data = self->_subset_struct(*self.data, column_indices, is_range[1], sub2)
    new_column_names = (*self.column_names)[column_indices]
  endif else begin
    case 1 of
      is_range[0] && is_range[1]: begin
          new_data = (*self.data)[sub1[0]:sub1[1]:sub1[2], $
                                  sub2[0]:sub2[1]:sub2[2]]
        end
      is_range[0]: new_data = (*self.data)[sub1[0]:sub1[1]:sub1[2], sub2]
      is_range[1]: new_data = (*self.data)[sub1, sub2[0]:sub2[1]:sub2[2]]
      else: new_data = (*self.data)[sub1, sub2]
    endcase
    new_column_names = n_elements(*self.column_names) eq 0L $
                         ? !null $
                         : (is_range[0] $
                              ? (*self.column_names)[sub1[0]:sub1[1]:sub1[2]] $
                              : (*self.column_names)[sub1])
  endelse

  new_table = mg_table(new_data, column_names=new_column_names)

  return, new_table
end


function mg_table::_overloadHelp, varname
  compile_opt strictarr

  _type = 'MG_TABLE'
  _specs = string(self.n_columns, self.n_rows, format='(%"<%d columns, %d rows>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


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

  ; TODO: handle complex types
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


function mg_table::_overloadSize
  compile_opt strictarr

  return, [self.n_columns, self.n_rows]
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

print, format='(%"# Simple array")'
iris = mg_load_iris()
df = mg_table(iris.data, column_names=iris.feature_names)
help, df
print, n_elements(df), format='(%"n_elements(df) = %d")'
print, strjoin(strtrim(size(df), 2), ', '), format='(%"size(df) = [%s]")'
print, df

print, format='(%"\n# Subtable of simple array")'
new_df = df[[0, 3], 0:49]
help, new_df
print, n_elements(new_df), format='(%"n_elements(new_df) = %d")'
print, strjoin(strtrim(size(new_df), 2), ', '), format='(%"size(new_df) = [%s]")'
print, new_df
obj_destroy, new_df

obj_destroy, df

print, format='(%"\n# Array of structures")'
data = [{price: 850000, rooms: 4, neighborhood: 'Queen Anne'}, $
        {price: 700000, rooms: 3, neighborhood: 'Fremont'}, $
        {price: 650000, rooms: 3, neighborhood: 'Wallingford'}, $
        {price: 600000, rooms: 2, neighborhood: 'Fremont'}]
df = mg_table(data, column_names=['price', 'rooms', 'neighborhood'])
help, df
print, n_elements(df), format='(%"n_elements(df) = %d")'
print, strjoin(strtrim(size(df), 2), ', '), format='(%"size(df) = [%s]")'
print, df

print, format='(%"\n# Subtable of array of structures")'
new_df = df[['neighborhood', 'price'], *]
help, new_df
print, n_elements(new_df), format='(%"n_elements(new_df) = %d")'
print, strjoin(strtrim(size(new_df), 2), ', '), format='(%"size(new_df) = [%s]")'
print, new_df

obj_destroy, df

venus_filename = filepath('VenusCraterData.csv', subdir=['examples', 'data'])

end

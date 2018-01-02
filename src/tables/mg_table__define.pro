; docformat = 'rst'

;= helper methods

;+
; Find the width of the terminal. If `MG_TERMCOLUMNS` is not available, returns
; 80.
;
; :Returns:
;   long
;-
function mg_table::_termcolumns
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, 80L
  endif

  n_cols = mg_termcolumns()
  return, n_cols
end


;+
; Subset a table returning an array of structures.
;
; :Returns:
;   array of structures
;
; :Params:
;   is_range : in, required, type=bytarr(2)
;     2-element array indicates if `ss1` and `ss2`, respectively, are ranges or
;     index arrays
;   ss1 : in, required, type=lonarr
;     if `is_range[0] eq 0` then index array, else it should be a 3-element
;     array of the form `[start, stop, stride]`
;   ss2 : in, required, type=lonarr
;     if `is_range[1] eq 0` then index array, else it should be a 3-element
;     array of the form `[start, stop, stride]`
;
; :Keywords:
;   column_names : out, optional, type=strarr
;     column names of the columns in the result
;-
function mg_table::_subset, is_range, ss1, ss2, column_names=column_names
  compile_opt strictarr

  self->getProperty, column_names=column_names
  if (is_range[0] eq 0) then begin
    column_names = column_names[ss1]
  endif else begin
    column_names = column_names[ss1[0]:ss1[1]:ss1[2]]
  endelse
  n_columns = n_elements(column_names)

  if (is_range[1] eq 0) then begin
    n_rows = n_elements(ss2)
  endif else begin
    last_index = (ss2[1] + self.n_rows) mod self.n_rows
    n_rows = ceil((last_index - ss2[0] + 1L) / float(ss2[2]))
  endelse

  result = {}
  for c = 0L, n_columns - 1L do begin
    col = (self.columns)[column_names[c]]
    result = create_struct(result, $
                           idl_validname(column_names[c], /convert_all), $
                           fix(0, type=col.type))
  endfor
  result = replicate(result, n_rows)

  for c = 0L, n_columns - 1L do begin
    col = (self.columns)[column_names[c]]
    result.(c) = col->_overloadBracketsRightSide([is_range[1]], ss2)
  endfor

  return, result
end


pro mg_table::_fix_widths, subset, widths
  compile_opt strictarr

  n_columns = n_tags(subset)
  for c = 0L, n_columns - 1L do begin
    type = size(subset.(c), /type)
    if (type eq 7L) then begin
      col = subset.(c)
      n_rows = n_elements(subset.(c))
      for r = 0L, n_rows - 1L do begin
        if (strlen(col[r]) gt widths[c]) then begin
          row_width = widths[r] - 3L
          ellipses = '...'
        endif else begin
          row_width = widths[r]
          ellipses = ''
        endelse
        col[r] = string(col[r], ellipses, format=mg_format('%*s%s', - row_width))
      endfor
      subset.(c) = col
    endif
  endfor
end


;+
; Return a string for the printed output, with rows optionally specified.
;
; :Returns:
;   `strarr(1, rows)`
;
; :Params:
;   first_row : in, optional, type=integer, default=0
;     index of first row to print
;   last_row : in, optional, type=integer, default=first_row + N_ROWS_TO_PRINT
;     index of last row to print; default is the `first_row` plus the
;     `N_ROWS_TO_PRINT` property
;-
function mg_table::_output, first_row, last_row
  compile_opt strictarr

  ; define the start and end rows
  _first_row = mg_default(first_row, 0L) > 0L
  _last_row = mg_default(last_row, _first_row + self.n_rows_to_print) < (self.n_rows - 1L)
  n_printed_rows = _last_row - _first_row + 1L

  ; define the size for the space for the index column
  n_index_spaces = ceil(alog10((self.n_rows - 1L) > 1L))

  ; define whether to print some elements of the output
  print_header = 1B
  print_head_ellipses = _first_row gt 0L
  print_tail_ellipses = _last_row lt (self.n_rows - 1L)

  ; define the format codes and their lengths for our columns
  formats = strarr(self.columns->count())
  c = 0L
  foreach col, self.columns do formats[c++] = col.format
  self->getProperty, widths=widths, column_names=column_names

  for c = 0L, n_elements(widths) - 1L do begin
    if (widths[c] gt strlen(column_names[c])) then begin
      column_names[c] = strjoin(strarr(widths[c] - strlen(column_names[c])) + ' ') + column_names[c]
    endif else begin
      if (widths[c] ne strlen(column_names[c])) then begin
        formats[c] = strjoin(strarr(strlen(column_names[c]) - widths[c]) + ' ') + formats[c]
      endif
    endelse
  endfor

  widths >= strlen(column_names)

  ; determine how many columns can fit on a screen and the number of sections
  screen_width = self->_termcolumns()
  sections = mg_partition(widths + 1, $
                          screen_width - n_index_spaces - 1, $
                          count=n_sections, indices=si)

  ; find size of result
  n_section_rows = 2 * print_header + print_head_ellipses $
                     + n_printed_rows $
                     + print_tail_ellipses
  result = strarr(1, n_sections * (n_section_rows) + n_sections - 1L)

  row_indices = lindgen(self.n_rows)

  ; loop through the sections
  for s = 0L, n_sections - 1L do begin
    ; format and their lengths for this section
    section_widths = widths[si[s]:si[s + 1] - 1]
    section_formats = formats[si[s]:si[s + 1] - 1]

    header_format = '(%"%' + strtrim(n_index_spaces, 2) + 's ' $
                      + strjoin('%' + strtrim(section_widths, 2) + 's', ' ') $
                      + '")'

    ellipses = strarr(sections[s]) + '...'

    if (print_header) then begin
      line = strarr(sections[s])
      for c = 0L, sections[s] - 1L do begin
        line[c] = strjoin(strarr(widths[c]) + '=')
      endfor

      i = n_section_rows * s + s
      result[i] = [string('', column_names[si[s]:si[s + 1] - 1], $
                          format=header_format), $
                   string('', line, format=header_format)]
    endif

    ; head ellipses
    if (print_head_ellipses) then begin
      i = 2 * print_header + n_section_rows * s + s
      result[i] = string('', ellipses, format=header_format)
    endif

    ; data
    data_format = '(%"%' + strtrim(n_index_spaces, 2) + 'd ' $
                    + strjoin(section_formats, ' ') + '")'

    i = 2 * print_header + print_head_ellipses + n_section_rows * s + s
    for r = 0L, n_printed_rows - 1L do begin
      column_indices = lindgen(si[s + 1] - si[s]) + si[s]
      subset = self->_subset([0B, 1B], $
                             column_indices, $
                             [lonarr(2) + r + _first_row, 1])
      self->_fix_widths, subset, section_widths
      result[i + r] = string(row_indices[r + _first_row], subset, $
                             format=data_format)
    endfor

    ; tail ellipses
    if (print_tail_ellipses) then begin
      i = (s + 1) * n_section_rows - 1 + s
      result[i] = string('', ellipses, format=header_format)
    endif
  endfor

  return, result
end


;= display methods

;+
; Display the first `n` lines of the table.
;
; :Params:
;   n : in, optional, type=integer, default=10
;     number of rows of data to display
;-
pro mg_table::head, n
  compile_opt strictarr

  print, self->_output(0, mg_default(n, 10))
end


;+
; Display the last `n` lines of the table.
;
; :Params:
;   n : in, optional, type=integer, default=10
;     number of rows of data to display
;-
pro mg_table::tail, n
  compile_opt strictarr

  print, self->_output(self.n_rows - mg_default(n, 10), self.n_rows - 1L)
end


;= plotting methods

;+
; Produce a scatter plot between column `x` and column `y`. If `x` and `y` are
; not specified, then produces a scatter plot matrix.
;
; :Params:
;   x : in, optional, type=string/integer
;     column name or index for `x` values of scatter plot
;   y : in, optional, type=string/integer
;     column name or index for `y` values of scatter plot
;-
pro mg_table::scatter, x, y, psym=psym, _extra=e
  compile_opt strictarr

  ; TODO: implement
end


;= stats methods


;= column methods

pro mg_table::move, src, dst
  compile_opt strictarr

  ; TODO: handle column names instead of just indices
  self.columns->move, src, dst
end


;= overload methods

pro mg_table::_overloadPlus, left, right
  compile_opt strictarr

  ; TODO: implement concatenation
end


pro mg_table::_overloadBracketsLeftSide, table, value, is_range, ss1, ss2
  compile_opt strictarr

  ; TODO: implement both column creation and reassignment to existing columns
end


;+
; Subset a table returning a new table.
;
; :Returns:
;   `mg_table`
;
; :Params:
;   is_range : in, required, type=bytarr(2)
;     2-element array indicates if `ss1` and `ss2`, respectively, are ranges or
;     index arrays
;   ss1 : in, required, type=lonarr
;     if `is_range[0] eq 0` then index array, else it should be a 3-element
;     array of the form `[start, stop, stride]`
;   ss2 : in, required, type=lonarr
;     if `is_range[1] eq 0` then index array, else it should be a 3-element
;     array of the form `[start, stop, stride]`
;-
function mg_table::_overloadBracketsRightSide, is_range, ss1, ss2
  compile_opt strictarr

  ; TODO: handle column names instead of indices
  subset = self->_subset(is_range, ss1, ss2, column_names=column_names)
  return, mg_table(subset, column_names=column_names)
end


;+
; Returns helpful string for `HELP`.
;
; :Examples:
;   For example::
;
;     IDL> help, df
;     DF              MG_TABLE  = <3 columns, 4 rows>
;
; :Returns:
;   string
;
; :Params:
;   varname : in, required, type=string
;     name of variable to retrieve `HELP` for
;-
function mg_table::_overloadHelp, varname
  compile_opt strictarr

  _type = 'MG_TABLE'
  _specs = string(self.columns->count(), self.n_rows, $
                  format='(%"<%d columns, %d rows>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;+
; Returns string used by implied print.
;-
function mg_table::_overloadImpliedPrint, varname
  compile_opt strictarr

  last_row = (self.n_rows < self.n_rows_to_print) - 1L
  return, self->_output(0L, last_row)
end


;+
; Returns string used by `PRINT`.
;-
function mg_table::_overloadPrint
  compile_opt strictarr

  last_row = (self.n_rows < self.n_rows_to_print) - 1L
  return, self->_output(0L, last_row)
end


function mg_table::_overloadSize
  compile_opt strictarr

  return, [self.columns->count(), self.n_rows]
end


;= creation methods

pro mg_table::_append_array, array, column_names=names
  compile_opt strictarr

  dims = size(array, /dimensions)
  self.n_rows = dims[1]
  if (n_elements(names) eq 0L) then names = 'c' + strtrim(lindgen(dims[0]), 2)
  for c = 0L, dims[0] - 1L do (self.columns)[names[c]] = mg_column(reform(array[c, *]))
end


pro mg_table::_append_structarr, structarr, column_names=names
  compile_opt strictarr
  on_error, 2

  n_columns = n_tags(structarr)
  if (n_elements(names) eq 0L) then names = tag_names(structarr)
  self.n_rows = n_elements(structarr.(0))
  for c = 0L, n_columns - 1L do begin
    if (n_elements(structarr.(c)) ne self.n_rows) then begin
      message, 'all columns must have the same number of elements'
    endif
    (self.columns)[c] = mg_column(structarr.(c))
  endfor
end


pro mg_table::_append_arrstruct, arrstruct, column_names=names
  compile_opt strictarr

  n_columns = n_tags(arrstruct)
  if (n_elements(names) eq 0L) then names = tag_names(arrstruct)
  self.n_rows = n_elements(arrstruct)
  for c = 0L, n_columns - 1L do (self.columns)[names[c]] = mg_column(arrstruct.(c))
end


;= property access methods

pro mg_table::setProperty
  compile_opt strictarr

end


pro mg_table::getProperty, column_names=column_names, $
                            data=data, $
                            format=format, $
                            types=types, $
                            widths=widths
  compile_opt strictarr

  if (arg_present(column_names)) then begin
    keys = self.columns->keys()
    column_names = keys->toArray()
    obj_destroy, keys
  endif

  if (arg_present(data)) then begin
    data = self->_subset([1B, 1B], [0L, -1L, 1L], [0L, -1L, 1L])
  endif

  if (arg_present(format)) then begin
    formats = strarr(self.columns->count())
    c = 0L
    foreach col, self.columns do formats[c++] = col.format
    format = strjoin(formats, ', ')
  endif

  if (arg_present(types)) then begin
    types = strarr(self.columns->count())
    c = 0L
    foreach col, self.columns do types[c++] = col.type
  endif

  if (arg_present(widths)) then begin
    widths = strarr(self.columns->count())
    c = 0L
    foreach col, self.columns do widths[c++] = col.width
  endif
end


;= lifecycle methods

pro mg_table::cleanup
  compile_opt strictarr

  foreach col, self.columns do obj_destroy, col
  obj_destroy, self.columns
end


;+
; Instantiate an mg_table object.
;
; :Returns:
;   1 for succcess, 0 for failure
;-
function mg_table::init, data, $
                          column_names=column_names, $
                          n_rows_to_print=n_rows_to_print
  compile_opt strictarr
  on_error, 2

  self.columns = orderedhash()
  self.n_rows_to_print = mg_default(n_rows_to_print, 20L)

  type = size(data, /type)
  if (type eq 8) then begin
    ; either array of structures or structure of arrays
    if (n_elements(data) eq 1L) then begin
      self->_append_structarr, data, column_names=column_names
    endif else begin
      self->_append_arrstruct, data, column_names=column_names
    endelse
  endif else begin
    self->_append_array, data, column_names=column_names
  endelse

  return, 1
end


;+
; Define mg_table class.
;-
pro mg_table__define
  compile_opt strictarr

  !null = {mg_table, inherits IDL_Object, $
           n_rows: 0L, $
           n_rows_to_print: 0L, $
           columns: obj_new()}
end


; main-level example program

print, format='(%"# Simple array")'
iris = mg_learn_dataset('iris')
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
data = [{price: 850000.0, rooms: 4, neighborhood: 'Queen Anne'}, $
        {price: 700000.0, rooms: 3, neighborhood: 'Fremont'}, $
        {price: 650000.0, rooms: 3, neighborhood: 'Wallingford'}, $
        {price: 600000.0, rooms: 2, neighborhood: 'Fremont'}]
df = mg_table(data, column_names=['price', 'rooms', 'neighborhood'])
help, df
print, n_elements(df), format='(%"n_elements(df) = %d")'
print, strjoin(strtrim(size(df), 2), ', '), format='(%"size(df) = [%s]")'
print, df

print, format='(%"\n# Subtable of array of structures")'
print, strjoin(df['neighborhood'], ', '), format='(%"Neighborhoods: %s")'
new_df = df[['neighborhood', 'price'], *]
help, new_df
print, n_elements(new_df), format='(%"n_elements(new_df) = %d")'
print, strjoin(strtrim(size(new_df), 2), ', '), format='(%"size(new_df) = [%s]")'
print, new_df

obj_destroy, df

print, format='(%"\n# Scatter plot between two columns")'
device, decomposed=0
loadct, 5
b = mg_learn_dataset('boston')
df = mg_table(b.data, column=b.feature_names)
df->scatter, 'NOX', 'AGE', $
             psym=mg_usersym(/circle, /fill), $
             symsize=0.5, $
             color=bytscl(df['RAD'])

venus_filename = filepath('VenusCraterData.csv', subdir=['examples', 'data'])

end

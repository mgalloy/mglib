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
;   array : in, optional, type=boolean
;     set to return a 2-dimensional array instead of an array of structures
;-
function mg_table::_subset, is_range, ss1, ss2, $
                            column_names=column_names, array=array
  compile_opt strictarr
  on_error, 2

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

  if (keyword_set(array)) then begin
    self->getProperty, types=types
    type = types[0]
    for t = 0L, n_elements(types) - 1L do begin
      type = mg_promote_type(type, types[t])
      if (type lt 0L) then message, 'no valid type for output array'
    endfor
    result = make_array(dimension=[n_columns, n_rows], type=type)
    for c = 0L, n_columns - 1L do begin
      col = (self.columns)[column_names[c]]
      result[c, *] = col->_overloadBracketsRightSide([is_range[1]], ss2)
    endfor
  endif else begin
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
  endelse

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

  if (self.columns->count() eq 0L) then return, '{}'

  ; define the start and end rows
  _first_row = mg_default(first_row, 0L) > 0L
  _last_row = mg_default(last_row, _first_row + self.n_rows_to_print) < (self.n_rows - 1L)
  n_printed_rows = _last_row - _first_row + 1L

  ; define the size for the space for the index column
  has_row_names = n_elements(*self.row_names) gt 0L
  if (has_row_names) then begin
    n_index_spaces = max(strlen(*self.row_names))
    row_names = *self.row_names
  endif else begin
    n_index_spaces = ceil(alog10((self.n_rows - 1L) > 1L))
    row_names = strtrim(sindgen(self.n_rows), 2)
  endelse

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
      line = strarr(sections[s] + 1L)
      line[0] = strjoin(strarr(n_index_spaces) + '=')
      for c = 0L, sections[s] - 1L do begin
        line[c + 1L] = strjoin(strarr(section_widths[c]) + '=')
      endfor

      i = n_section_rows * s + s
      result[i] = [string('', column_names[si[s]:si[s + 1] - 1], $
                          format=header_format), $
                   string(line, format=header_format)]
    endif

    ; head ellipses
    if (print_head_ellipses) then begin
      i = 2 * print_header + n_section_rows * s + s
      result[i] = string('', ellipses, format=header_format)
    endif

    ; data
    data_format = '(%"%' + strtrim(n_index_spaces, 2) + 's ' $
                    + strjoin(section_formats, ' ') + '")'

    i = 2 * print_header + print_head_ellipses + n_section_rows * s + s
    for r = 0L, n_printed_rows - 1L do begin
      column_indices = lindgen(si[s + 1] - si[s]) + si[s]
      subset = self->_subset([0B, 1B], $
                             column_indices, $
                             [lonarr(2) + r + _first_row, 1])
      self->_fix_widths, subset, section_widths
      result[i + r] = string(row_names[r + _first_row], subset, $
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


;+
; Helper routine to convert an array of column names to column indices.
;
; :Returns:
;   long/lonarr
;
; :Params:
;   names : in, required, type=string/strarr
;     string or array of strings representing column names
;-
function mg_table::_names2indices, names
  compile_opt strictarr
  on_error, 2

  self->getProperty, column_names=column_names
  n_names = n_elements(names)
  indices = lonarr(n_names)
  for n = 0L, n_names - 1L do begin
    ind = where(strmatch(column_names, names[n], fold_case=self.fold_case), count)
    if (count eq 0L) then begin
      message, string(names[n], format='(%"column name %s not found")')
    endif
    indices[n] = ind[0]
  endfor

  return, size(names, /dimensions) eq 0 ? indices[0] : indices
end


;+
; Helper routine to convert an array of column indices to column names.
;
; :Returns:
;   string/strarr
;
; :Params:
;   indices : in, required, type=lonarr
;     index array or range
;-
function mg_table::_indices2names, is_range, indices
  compile_opt strictarr

  self->getProperty, column_names=column_names
  n_columns = n_elements(column_names)

  if (is_range) then begin
    if (indices[1] lt n_columns) then begin
      names = column_names[indices[0]:indices[1]:indices[2]]
    endif else begin
      new_indices = lindgen(indices[1] + 1)
      return, self->_indices2names(0B, new_indices[indices[0]:indices[1]:indices[2]])
    endelse
  endif else begin
    if (max(indices) lt n_columns) then begin
      names = column_names[indices]
    endif else begin
      names = strarr(n_elements(indices))
      c = n_columns + 1L
      for i = 0L, n_elements(indices) - 1L do begin
        if (indices[i] lt n_columns) then begin
          names[i] = column_names[indices[i]]
        endif else begin
          suggested_name = string(c++, format='(%"c%d")')
          while (self->has_column(suggested_name)) do begin
            suggested_name = string(c++, format='(%"c%d")')
          endwhile
          names[i] = suggested_name
        endelse
      endfor
    endelse
  endelse

  return, names
end


pro mg_table::_assign_column, name, value
  compile_opt strictarr

  n_rows = n_elements(value)

  if (self.n_rows ne 0L && n_rows ne self.n_rows) then begin
    message, 'new column must have the same number of rows as table'
  endif else self.n_rows = n_rows   ; adding column to empty table

  (self.columns)[name] = mg_column(value)
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


;+
; Page through entire output of the table.
;-
pro mg_table::page
  compile_opt strictarr

  more, self->_output(0L, self.n_rows - 1L)
end


;= export methods

;+
; Export HTML representing the table.
;-
function mg_table::to_html, class=class, id=id
  compile_opt strictarr

  html = strarr(self.n_rows + 3L)
  c = 0L
  foreach col, self.columns, name do begin
    html[1] += '<th>' + name + '</th>'
    html[2:-2] += col->to_html()
    c += 1L
  endforeach

  _class = n_elements(class) gt 0L ? string(class, format='(%" class=\"%s\"")') : ''
  _id = n_elements(id) gt 0L ? string(id, format='(%" id=\"%s\"")') : ''

  html[0] = '<table' + _class + _id + '>'
  html[1] = '<tr>' + html[1] + '</tr>'
  html[2:-2] = '<tr>' + html[2:-2] + '</tr>'
  html[-1] = '</table>'

  return, html
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
  on_error, 2

  self->getProperty, column_names=column_names
  case n_params() of
    0: begin
        self->getProperty, data=data
        mg_scatterplot_matrix, data, column_names=column_names, $
                               psym=psym, _extra=e
      end
    1: message, 'only one column specified'
    2: begin
        xdata = self[x]
        ydata = self[y]
        xtitle = size(x, /type) eq 7 ? x : column_names[x]
        ytitle = size(y, /type) eq 7 ? y : column_names[y]
        mg_plot, xdata, ydata, xtitle=xtitle, ytitle=ytitle, /nodata
        mg_plots, xdata, ydata, psym=mg_default(psym, 3), _extra=e
      end
  endcase
end


;= stats methods

function mg_table::stats, percentiles=percentiles
  compile_opt strictarr

  _percentiles = mg_default(percentiles, [0.25, 0.50, 0.75])
  n_columns = self.columns->count()
  n_rows = n_elements(_percentiles) + 4L  ; mean, stddev, min, max
  result = fltarr(n_columns, n_rows)
  c = 0L
  foreach col, self.columns, key do begin
    d = col.data
    range = mg_range(d)
    per = mg_percentiles(d, percentiles=_percentiles)
    result[c, *] = [mean(d), stddev(d), range[0], per, range[1]]
    c += 1L
  endforeach

  self->getProperty, column_names=column_names
  row_names = ['mean', 'std dev', 'min', string(100.0 * _percentiles, format='(F0.1)') + '%', 'max']
  return, mg_table(result, column_names=column_names, row_names=row_names)
end


pro mg_table::describe, percentiles=percentiles, description_table=description_table
  compile_opt strictarr

  description_table = self->stats(percentiles=percentiles)
  print, description_table
  if (~arg_present(description_table)) then obj_destroy, description_table
end


;= column methods

pro mg_table::drop_column, name
  compile_opt strictarr

  _name = size(name, /type) eq 7 ? name : self->_indices2names(0, name)
  self.columns->remove, _name
end


function mg_table::has_column, name
  compile_opt strictarr

  return, self.columns->hasKey(name)
end


pro mg_table::move_column, src, dst
  compile_opt strictarr

  _src = size(src, /type) eq 7 ? self->_names2indices(src) : src
  _dst = size(dst, /type) eq 7 ? self->_names2indices(dst) : dst
  self.columns->move, _src, _dst
end


;= overload methods

function mg_table::_overloadPlus, left, right
  compile_opt strictarr
  ;on_error, 2

  if (left.n_rows ne right.n_rows) then begin
    message, 'can only concatenate tables with the same number of rows'
  endif

  new_table = mg_table()

  foreach col, left.columns, key do begin
    print, key, format='(%"adding %s from left table")'
    new_table[key] = col.data
  endforeach

  foreach col, right.columns, key do begin
    print, key, format='(%"adding %s from right table")'
    new_key = key
    while (new_table->has_column(new_key)) do new_key += '_'
    new_table[new_key] = col.data
  endforeach

  print, new_table.columns->count(), format='(%"%d columns in new table")'

  return, new_table
end


pro mg_table::_overloadBracketsLeftSide, table, value, is_range, ss1, ss2
  compile_opt strictarr
  on_error, 2

  ; TODO: handle indexing rows, i.e., use is_range[1] and ss2
  if (n_elements(ss2) gt 0L) then message, 'indexing rows on assignment not implemented'

  col_names = size(ss1, /type) eq 7 ? ss1 : self->_indices2names(is_range[0], ss1)

  n_columns = n_elements(col_names)

  if (size(value, /type) eq 11) then begin
    is_column = obj_isa(value, 'mg_column')
    case 1 of
      obj_isa(value, 'mg_table'):
      n_elements(is_column) eq 1 && is_column[0] eq 1:
      mg_all(is_column):
      else: message, 'assigned value must be a table, column, array of columns, or numeric array'
    endcase
  endif else begin
    n_dims = size(value, /n_dimensions)
    if (n_dims ne 1 && n_dims ne 2) then begin
      message, 'assigned value must be 1- or 2-dimensional'
    endif

    dims = size(value, /dimensions)

    case 1 of
      n_dims eq 1: n_rows = n_elements(value)
      dims[0] ne n_columns: message, 'mismatching number of columns in assignment'
      else: n_rows = dims[1]  ; everything OK
    endcase

    case 1 of
      self.n_rows eq 0L:
      n_rows ne self.n_rows: message, 'mismatching number of rows in column'
      else:   ; everything OK
    endcase
  endelse

  if (size(value, /type) eq 11) then begin
    ; could be an array of columns, a column, or a table
    is_column = obj_isa(value, 'mg_column')
    case 1 of
      n_elements(is_column) gt 1L: begin
          for c = 0L, n_columns - 1L do begin
            self->_assign_column, col_names[c], value[c]
          endfor
        end
      obj_isa(value, 'mg_column'): for c = 0L, n_columns - 1L do self->_assign_column, col_names[c], value
      obj_isa(value, 'mg_table'): begin
          value->getProperty, columns=cols
          c = 0
          foreach col, cols do begin
            self->_assign_column, col_names[c], col
            c += 1
          endforeach
        end
      else:
    endcase
  endif else begin
    for c = 0L, n_columns - 1L do begin
      self->_assign_column, col_names[c], $
                            size(value, /n_dimensions) eq 1 ? value : value[c, *]
    endfor
  endelse
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
  on_error, 2

  _ss1 = size(ss1, /type) eq 7 ? self->_names2indices(ss1) : ss1
  if (n_elements(is_range) eq 1L) then begin
    is_range = [is_range[0], 1]
    _ss2 = [0, self.n_rows - 1L, 1]
  endif else _ss2 = ss2

  subset = self->_subset(is_range, _ss1, _ss2, column_names=column_names)
  if (n_tags(subset) eq 1L) then return, subset.(0)

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

pro mg_table::append_array, array, column_names=names, column_widths=widths
  compile_opt strictarr

  dims = size(array, /dimensions)
  if (dims[0] eq 0L) then return
  self.n_rows = dims[1]
  if (n_elements(names) eq 0L) then names = 'c' + strtrim(lindgen(dims[0]) + 1L, 2)
  for c = 0L, dims[0] - 1L do begin
    col = mg_column(reform(array[c, *]))
    if (n_elements(widths) gt 0L) then col.width = widths[c]
    (self.columns)[names[c]] = col
  endfor
end


pro mg_table::append_structarr, structarr, column_names=names, column_widths=widths
  compile_opt strictarr
  on_error, 2

  n_columns = n_tags(structarr)
  _names = mg_default(names, tag_names(structarr))
  self.n_rows = n_elements(structarr.(0))
  for c = 0L, n_columns - 1L do begin
    if (n_elements(structarr.(c)) ne self.n_rows) then begin
      message, 'all columns must have the same number of elements'
    endif
    col = mg_column(structarr.(c))
    if (n_elements(widths) gt 0L) then col.width = widths[c]
    (self.columns)[_names[c]] = col
  endfor
end


pro mg_table::append_arrstruct, arrstruct, column_names=names, column_widths=widths
  compile_opt strictarr

  n_columns = n_tags(arrstruct)
  if (n_elements(names) eq 0L) then names = tag_names(arrstruct)
  self.n_rows = n_elements(arrstruct)
  for c = 0L, n_columns - 1L do begin
    col = mg_column(arrstruct.(c))
    if (n_elements(widths) gt 0L) then col.width = widths[c]
    (self.columns)[names[c]] = col
  endfor
end


;= property access methods

pro mg_table::setProperty, n_rows_to_print=n_rows_to_print, $
                           column=column, $
                           _extra=e
  compile_opt strictarr

  if (n_elements(n_rows_to_print) gt 0L) then begin
    self.n_rows_to_print = n_rows_to_print
  endif

  if (n_elements(column) gt 0L) then begin
    (self.columns[column])->setProperty, _extra=e
  endif
end


pro mg_table::getProperty, array=array, $
                           column_names=column_names, $
                           columns=columns, $
                           data=data, $
                           format=format, $
                           n_rows=n_rows, $
                           row_names=row_names, $
                           types=types, $
                           widths=widths
  compile_opt strictarr

  if (arg_present(array)) then begin
    array = self->_subset([1B, 1B], [0L, -1L, 1L], [0L, -1L, 1L], /array)
  endif

  if (arg_present(column_names)) then begin
    keys = self.columns->keys()
    column_names = keys->toArray()
    obj_destroy, keys
  endif

  if (arg_present(columns)) then columns = self.columns

  if (arg_present(data)) then begin
    data = self->_subset([1B, 1B], [0L, -1L, 1L], [0L, -1L, 1L])
    if (n_tags(data) eq 1L) then data = data.(0)
  endif

  if (arg_present(format)) then begin
    formats = strarr(self.columns->count())
    c = 0L
    foreach col, self.columns do formats[c++] = col.format
    format = strjoin(formats, ', ')
  endif

  if (arg_present(n_rows)) then n_rows = self.n_rows
  if (arg_present(row_names)) then row_names = *self.row_names

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
  ptr_free, self.row_names
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
                         column_widths=column_widths, $
                         fold_case=fold_case, $
                         n_rows_to_print=n_rows_to_print, $
                         row_names=row_names
  compile_opt strictarr
  on_error, 2

  self.fold_case = keyword_set(fold_case)
  self.columns = orderedhash(fold_case=self.fold_case)
  self.n_rows_to_print = mg_default(n_rows_to_print, 20L)

  type = size(data, /type)
  if (type eq 8) then begin
    ; either array of structures or structure of arrays
    if (n_elements(data) eq 1L) then begin
      self->append_structarr, data, $
                              column_names=column_names, $
                              column_widths=column_widths
    endif else begin
      self->append_arrstruct, data, $
                              column_names=column_names, $
                              column_widths=column_widths
    endelse
  endif else begin
    self->append_array, data, $
                        column_names=column_names, $
                        column_widths=column_widths
  endelse

  self.row_names = ptr_new(row_names)

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
           row_names: ptr_new(), $
           columns: obj_new(), $
           fold_case: 0B}
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
loadct, 55
tvlct, 255, 255, 255, 0
tvlct, 0, 0, 0, 255

b = mg_learn_dataset('boston')
df = mg_table(b.data, column=b.feature_names)
mg_window, xsize=4, ysize=4, /inches, title='NOX vs AGE', /free
df->scatter, 'NOX', 'AGE', $
             psym=mg_usersym(/circle, /fill), $
             symsize=0.5, $
             color=bytscl(df['RAD'], top=253) + 1B
mg_window, xsize=8, ysize=8, /inches, title='Scatterplot matrix', /free
df->scatter, bar_color=200, charsize=0.7, $
             xticks=1, yticks=1, xtickformat='(F0.1)', ytickformat='(F0.1)'

print, df
obj_destroy, df

venus_filename = filepath('VenusCraterData.csv', subdir=['examples', 'data'])
venus_table = mg_read_table(venus_filename)
print, venus_table
obj_destroy, venus_table

end

; docformat = 'rst'

pro mg_read_table_read, data, lun, column_types
  compile_opt strictarr

  n_rows = n_elements(data)
  n_columns = n_tags(data[0])
  line = ''
  for r = 0L, n_rows - 1L do begin
    readf, lun, line
    tokens = strtrim(strsplit(line, ',', /extract), 2)
    for c = 0L, n_columns - 1L do data[r].(c) = fix(tokens[c], type=column_types[c])
  endfor
end


;+
; Guess the type of a value represented as a string.
;
; :Private:
;
; :Returns:
;   long (type code)
;
; :Params:
;   value : in, required, type=string
;     string to guess type of
;-
function mg_read_table_gettype, value
  compile_opt strictarr

  re_integer = '^-?[[:space:]]*[[:digit:]]+$'
  re_float = '^-?[[:space:]]*([[:digit:]]+\.|\.[[:digit:]]+|[[:digit:]]+\.[[:digit:]]+)$'

  case 1 of
    stregex(value, re_float, /boolean): type = 4
    stregex(value, re_integer, /boolean): type = 3
    else: type = 7
  endcase

  return, type
end


;+
; Guess the types of all the values on a line.
;
; :Private:
;
; :Returns:
;   `lonarr` (type codes)
;
; :Params:
;   lun : in, required, type=integer
;     logical unit number to get line from
;
; :Keywords:
;   tokens : out, optional, type=strarr
;     set to a named variable to retrieve the string values of the tokens on
;     the line
;-
function mg_read_table_gettypes_forline, lun, names=tokens
  compile_opt strictarr

  point_lun, -lun, pos
  line = ''
  readf, lun, line
  point_lun, lun, pos

  tokens = strtrim(strsplit(line, ',', /extract, count=n_columns), 2)
  types = lonarr(n_columns)
  for c = 0L, n_columns - 1L do begin
    types[c] = mg_read_table_gettype(tokens[c])
  endfor

  return, types
end


;+
; Read CSV file (or space/tab delimited, if `COLUMN_NAMES` and `COLUMN_TYPES`
; are specified).
;
; :Returns:
;   `mg_table`
;
; :Params:
;   filename : in, required, type=string
;     filename to read
;
; :Keywords:
;   column_types : in, optional, type=lonarr
;     column types using the same codes as `SIZE`; if not present, reads the
;     first line after `COLUMN_NAMES` has been determined and tries to guess
;     the types of the values
;   column_names : in, optional, type=strarr
;     column names; if not present, reads the first non-skipped line and if
;     the values are not numeric, then uses them as the column names
;   skip : in, optional, type=integer
;     number of lines to skip at the beginning of the file
;-
function mg_read_table, filename, $
                        column_types=column_types, $
                        column_names=column_names, $
                        skip=skip
  compile_opt strictarr

  n_lines = file_lines(filename)

  openr, lun, filename, /get_lun
  if (n_elements(skip) gt 0L) then begin
    header = strarr(skip)
    readf, lun, header
    n_lines -= skip
  endif

  ; determine column names
  if (n_elements(column_names) eq 0L) then begin
    _header_types = mg_read_table_gettypes_forline(lun, names=_header_names)
    if (mg_all(_header_types eq 7)) then begin
        _column_names = _header_names
        line = ''
        readf, lun, line
        n_lines -= 1
    endif else begin
      message, 'no column names could be found or were given'
    endelse
  endif else begin
    _column_names = column_names
  endelse

  ; determine column types
  if (n_elements(column_types) eq 0L) then begin
    _column_types = mg_read_table_gettypes_forline(lun)
  endif else begin
    _column_types = column_types
  endelse

  for c = 0L, n_elements(_column_types) - 1L do begin
    if (c eq 0L) then begin
      s = create_struct(idl_validname(_column_names[c], /convert_all), fix(0, type=_column_types[c]))
    endif else begin
      s = create_struct(s, idl_validname(_column_names[c], /convert_all), fix(0, type=_column_types[c]))
    endelse
  endfor

  data = replicate(s, n_lines)

  ; need to read line by line if any string column types
  if (mg_any(_column_types eq 7)) then begin
    mg_read_table_read, data, lun, _column_types
  endif else begin
    readf, lun, data
  endelse

  free_lun, lun
  return, mg_table(data, column_names=_column_names)
end


; main-level example program

col_names = ['lon', 'lat', 'elev', 'temp', 'dewpt', 'wind_speed', 'wind_dir']
df = mg_read_table(file_which('ascii.txt'), skip=5, column_names=col_names)
print, df
obj_destroy, df

print

; this file is in the "canonical form": the first line has the column names and
; there is no other header to skip, making this the simplest calling sequence
df = mg_read_table(filepath('ascii.csv', root=mg_src_root()))
print, df[*, 0:4]
obj_destroy, df

print

; read a file with a string column
df = mg_read_table(filepath('test.csv', root=mg_src_root()))
print, df
obj_destroy, df

end

; docformat = 'rst'

;+
; Convert byte array to string with printable characters. Converts
; non-printable characters to '.' (ASCII 46).
;
; :Returns:
;   string
;
; :Params:
;   data : in, required, type=bytarr
;     data to convert
;-
function mg_hex_dump_makeprintable, data
  compile_opt strictarr

  _data = data

  nonprintable = where(_data lt 32B or _data gt 126B, n_nonprintable)
  if (n_nonprintable gt 0) then _data[nonprintable] = 46B

  return, string(_data)
end


;+
; Returns the width of the terminal. Default is 80L columns if `mg_termcolumns`
; is not found.
;
; :Private:
;
; :Returns:
;   long
;-
function mg_hex_dump_termcolumns
  compile_opt strictarr

  catch, error
  if (error ne 0) then begin
    catch, /cancel
    return, 80L
  endif

  return, mg_termcolumns()
end


;+
; Display hex dump of contents of a file or a numeric array.
;
; :Params:
;   filename : in, required, type=string or numeric array
;     filename of file to read and display, or, if `DATA` is set, a numeric
;     array to display
;
; :Keywords:
;   data : in, optional, type=boolean
;     set to indicate `filename` is actually a numeric array
;   term_width : in, optional, type=long
;     set to width of terminal display, by default, uses `mg_termcolumns` to
;     find terminal with, or 100L if `mg_termcolumns` not available
;   group_size : in, optional, type=long, default=4L
;     number of bytes per display group
;   n_columns : in, optional, type=long
;     number of groups across, by default fits as many groups as allowed by
;     `term_width` and `group_size`
;   more : in, optional, type=boolean
;     set to page output
;-
pro mg_hex_dump, filename, data=data, $
                 term_width=term_width, $
                 group_size=group_size, $
                 n_columns=n_columns, $
                 more=more
  compile_opt strictarr
  on_error, 2

  _term_width = n_elements(term_width) eq 0L $
                  ? mg_hex_dump_termcolumns() $
                  : term_width
  ; bytes per group
  _group_size = n_elements(group_size) eq 0L ? 4L : group_size

  _n_columns = n_elements(n_columns) eq 0L $
                 ? (_term_width - 1L) / (3L * _group_size + 1L) $
                 : n_columns

  ; read filename as flat binary data
  if (keyword_set(data)) then begin
    n = n_elements(filename)
    case size(filename, /type) of
      1: _data = filename
      2: _data = byte(filename, 0, n * 2)
      3: _data = byte(filename, 0, n * 4)
      4: _data = byte(filename, 0, n * 4)
      5: _data = byte(filename, 0, n * 8)
      6: _data = byte(filename, 0, n * 8)
      7: _data = byte(filename)
      9: _data = byte(filename, 0, n * 16)
      12: _data = byte(filename, 0, n * 2)
      13: _data = byte(filename, 0, n * 4)
      14: _data = byte(filename, 0, n * 8)
      15: _data = byte(filename, 0, n * 8)
      else: message, 'unsupported data type'
    endcase
    n_bytes = n_elements(_data)
  endif else begin
    openr, lun, filename, /get_lun
    info = fstat(lun)
    n_bytes = info.size
    _data = bytarr(n_bytes)
    readu, lun, _data
    free_lun, lun
  endelse

  ; pad data with 0's and make 2-dimensional
  n_pad = _group_size * _n_columns - n_bytes mod (_group_size * _n_columns)
  if (n_pad gt 0) then _data = [_data, bytarr(n_pad)]

  n_rows = (n_bytes + n_pad) / (_group_size * _n_columns)
  _data = reform(_data, _group_size * _n_columns, n_rows)
  strings = mg_hex_dump_makeprintable(_data)

  one_group_fmt = strtrim(_group_size, 2) + '(Z02)'
  fmt = '(' + strjoin(strarr(_n_columns) + one_group_fmt, ', " ", ') + ', "  ", A)'
  if (keyword_set(more)) then begin
    openw, lun, filepath(/terminal), /get_lun, /more
  endif else begin
    lun = -1
  endelse

  for r = 0L, n_rows - 1L do begin
    printf, lun, _data[*, r], strings[r], format=fmt
  endfor
end


; main-level example

mg_hex_dump, file_which('abnorm.dat')
print
mg_hex_dump, randomu(seed, 100) * 255.0, /data, group_size=8L

end

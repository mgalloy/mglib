; docformat = 'rst'

;= export methods

function mg_column::to_html
  compile_opt strictarr

  n_rows = n_elements(*self.data)

  html = strarr(n_rows)
  for r = 0L, n_rows - 1L do begin
    html[r] = strtrim(string((*self.data)[r], format=self.format), 2)
  endfor
  html = '<td>' + html + '</td>'

  return, html
end


;= overload methods

pro mg_column::_overloadBracketsLeftSide, col, value, is_range, ss1
  compile_opt strictarr

  if (is_range[0]) then begin
    (*self.data)[ss1[0]:ss1[1]:ss1[2]] = value
  endif else begin
    (*self.data)[ss1] = value
  endelse
end


function mg_column::_overloadBracketsRightSide, is_range, ss1
  compile_opt strictarr

  if (is_range[0]) then begin
    result = (*self.data)[ss1[0]:ss1[1]:ss1[2]]
  endif else begin
    result = (*self.data)[ss1]
  endelse

  return, result
end


function mg_column::_overloadHelp, varname
  compile_opt strictarr

  _type = 'MG_COLUMN'
  _specs = string(n_elements(*self.data), format='(%"<%d rows>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


function mg_column::_overloadImpliedPrint, varname
  compile_opt strictarr

  return, string(*self.data, /implied_print)
end


function mg_column::_overloadPrint
  compile_opt strictarr

  return, string(*self.data)
end


function mg_column::_overloadSize
  compile_opt strictarr

  return, size(*self.data, /dimensions)
end


;= property access methods

pro mg_column::setProperty, format=format
  compile_opt strictarr

  if (n_elements(format) gt 0L) then begin
    self.format = format
    re = '%([[:digit:]])?(.[[:digit:]]+)?[[:alpha:]]'
    tokens = stregex(format, re, /extract, /subexpr)
    if (tokens[1] eq '') then begin
      ; TODO: should capture [[:alpha:]] and lookup default width
      width = mg_default_format(self.type, /width)
    endif else begin
      width = long(tokens[1])
    endelse
    self.width = width
  endif
end


pro mg_column::getProperty, data=data, type=type, format=format, n_rows=n_rows, width=width
  compile_opt strictarr

  if (arg_present(data)) then data = *self.data
  if (arg_present(type)) then type = self.type
  if (arg_present(format)) then format = self.format
  if (arg_present(n_rows)) then n_rows = n_elements(*self.data)
  if (arg_present(width)) then width = self.width
end


;= lifecycle methods

pro mg_column::cleanup
  compile_opt strictarr

  ptr_free, self.data
end


;+
; Create column from some data or another column.
;
; :Returns:
;   1 for success, 0 for failure
;
; :Params:
;   data : in, required, type=mg_column or numeric array
;     data of the column, if `mg_column`, creates a copy
;-
function mg_column::init, data
  compile_opt strictarr

  if (size(data, /type) eq 11) then begin
    is_column = obj_isa(data, 'mg_column')
    if (n_elements(is_column) eq 1 && is_column) then begin
      self.data = ptr_new(data.data)
      self.type = data.type
      self.format = data.format
      self.width = data.width
    endif else begin
      message, 'invalid column data object'
    endelse
  endif else begin
    self.data = ptr_new(data)
    self.type = size(data, /type)
    self.format = mg_default_format(self.type)
    self.width = mg_default_format(self.type, /width)
  endelse

  return, 1
end


pro mg_column__define
  compile_opt strictarr

  !null = {mg_column, inherits IDL_Object, $
           type: 0L, $
           format: '', $
           width: 0L, $
           data: ptr_new()}
end


; main-level example program

c = mg_column(findgen(20))
help, c
c[0:4] = 2 * findgen(5)
print, c[3:6]

end

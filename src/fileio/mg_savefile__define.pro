; docformat = 'rst'


;+
; Subclass of IDL_Savefile that provides easier to use functionality for
; examining the contents of a save file.
;
; :Examples:
;    Try the main-level example at the end of this file::
; 
;       IDL> .run mg_savefile__define
;-


;+
; Print the help string for all the regular variables in a .sav file.
;
; :Params:
;    varname : in, required, type=any
;       variable to find declaration statement for
;-
function mg_savefile::_overloadHelp, varname
  compile_opt strictarr

  result = ''
  arrformat = '(%"%-15s %-9s = Array[%s]%s")'
  scalarformat = '(%"%-15s %-9s = %s%s")'
  typenames = ['UNDEFINED', 'BYTE', 'INT', 'LONG', 'FLOAT', 'DOUBLE', $
               'STRING', 'STRUCTURE', 'DCOMPLEX', 'POINTER', 'OBJREF', $
               'UINT', 'ULONG', 'LONG64', 'ULONG64']
               
  varnames = self->names(count=nvars)
  for v = 0L, nvars - 1L do begin
    type = self->size(varnames[v], /type)
    ndims = self->size(varnames[v], /n_dimensions)
    dims = strjoin(strtrim(self->size(varnames[v], /dimensions), 2), ', ')

    if (ndims gt 0) then begin
      result += string(varnames[v], typenames[type], dims, mg_newline(), $
                       format=arrformat)
    endif else begin
      value = self->get(varnames[v])
      help, value, output=output
      pos = strsplit(output, len=len)
      repr = strmid(output, pos[3])
      result += string(varnames[v], typenames[type], repr, $
                       mg_newline(), $
                       format=scalarformat)
    endelse
  endfor

  ; remove the last (extra) newline
  result = strmid(result, 0, strlen(result) - strlen(mg_newline()))
  if (result eq '') then result = 'no regular IDL variables'
  
  return, result
end


;+
; Returns names of each type of save file item in the file.
;
; :Returns:
;    string
;-
function mg_savefile::_overloadPrint
  compile_opt strictarr

  result = ''
  noneformat = '(%"%s: 0%s")'
  format = '(%"%s: %d (%s)%s")'

  varnames = self->names(count=nvars)
  if (nvars eq 0L) then begin
    result += string('Variables', mg_newline(), format=noneformat)
  endif else begin
    result += string('Variables', nvars, strjoin(varnames, ', '), $
                     mg_newline(), $
                     format=format)
  endelse

  commonnames = self->names(count=ncommon, /common_block)
  if (ncommon eq 0L) then begin
    result += string('Common blocks', mg_newline(), format=noneformat)
  endif else begin
    result += string('Common blocks', ncommon, strjoin(commonnames, ', '), $
                     mg_newline(), $
                     format=format)
  endelse

  sysvarnames = self->names(count=nsysvar, /system_variable)
  if (nsysvar eq 0L) then begin
    result += string('System variables', mg_newline(), format=noneformat)
  endif else begin
    result += string('System variables', nsysvar, strjoin(sysvarnames, ', '), $
                     mg_newline(), $
                     format=format)
  endelse

  objectnames = self->names(count=nobjs, /object_heapvar)
  if (nobjs eq 0L) then begin
    result += string('Object heap variables', mg_newline(), format=noneformat)
  endif else begin
    result += string('Object heap variables', nobjs, $
                     strjoin(strtrim(objectnames, 2), ', '), $
                     mg_newline(), $
                     format=format)
  endelse
  
  ptrnames = self->names(count=nptrs, /pointer_heapvar)
  if (nptrs eq 0L) then begin
    result += string('Pointer heap variables', mg_newline(), format=noneformat)
  endif else begin
    result += string('Pointer heap variables', nptrs, $
                     strjoin(strtrim(ptrnames, 2), ', '), $
                     mg_newline(), $
                     format=format)
  endelse

  structnames = self->names(count=nstrdef, /structure_definition)
  if (nstrdef eq 0L) then begin
    result += string('Functions', mg_newline(), format=noneformat)
  endif else begin
    result += string('Functions', nstrdef, strjoin(structnames, ', '), $
                     mg_newline(), $
                     format=format)
  endelse
      
  functionnames = self->names(count=nfunction, /function)
  if (nfunction eq 0L) then begin
    result += string('Functions', mg_newline(), format=noneformat)
  endif else begin
    result += string('Functions', nfunction, strjoin(functionnames, ', '), $
                     mg_newline(), $
                     format=format)
  endelse
  
  procedurenames = self->names(count=nprocedures, /procedure)
  if (nprocedures eq 0L) then begin
    result += string('Procedures', mg_newline(), format=noneformat)
  endif else begin
    result += string('Procedures', nprocedures, strjoin(procedurenames, ', '), $
                     mg_newline(), $
                     format=format)
  endelse
        
  result = strmid(result, 0, strlen(result) - strlen(mg_newline()))

  return, result
end


;+
; Allow hash-like subscripting to retrieve variable values.
;
; :Returns:
;    string
;
; :Params:
;    isRange : in, required, type=lonarr
;       whether each corresponding index is a range
;    ss1 : in, required, type=string
;       name of variable to extract
;-
function mg_savefile::_overloadBracketsRightSide, isRange, ss1
  compile_opt strictarr
  on_error, 2

  if (isRange[0] gt 0) then message, 'ranges not allowed'
  
  return, self->get(ss1)
end


;+
; Return a particular item in the .sav file.
;
; :Returns:
;    save file item, if a standard variable
;
; :Keywords:
;    _ref_extra : in, out, optional, type=keywords
;       keywords to IDL_Savefile::restore
;-
function mg_savefile::get, saveitem, _ref_extra=e
  compile_opt strictarr
  
  self->restore, saveitem, _extra=e
  
  isVar = 1B
  for el = 0L, n_elements(e) - 1L do begin
    if (e[el] ne 'COUNT') then isVar = 0B
  endfor
  
  return, isVar ? scope_varfetch(saveitem) : !null
end


;+
; :Returns:
;    1 for success, 0 for failure
;
; :Params:
;    filename : in, optional, type=string
;       filename of save file
;
; :Keywords:
;    _extra : in, optional, type=keywords
;       keywords to IDL_Savefile
;-
function mg_savefile::init, filename, _extra=e
  compile_opt strictarr
  
  if (~self->IDL_Object::init()) then return, 0
  if (~self->IDL_Savefile::init(filename, _extra=e)) then return, 0
  
  return, 1
end


;+
; Define instance variables and inheritance.
;-
pro mg_savefile__define
  compile_opt strictarr
  
  define = { MG_Savefile, inherits IDL_Object, inherits IDL_Savefile }
end


; main-level program example

s = mg_savefile(file_which('cow10.sav'))
help, s
print, s

r = 0.5
p = plot3d([- r, r], [- r, r], [- r, r], axis_style=0, /nodata)
p = polygon([[s['x']], [s['y']], [s['z']]], connectivity=s['polylist'], /data)

end

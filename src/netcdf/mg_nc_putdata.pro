; docformat = 'rst'

function mg_nc_putdata_checkdimname, file_id, dim_name, found=found
  compile_opt strictarr

  found = 0B
  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, -1
  endif

  id = ncdf_dimid(file_id, dim_names[i])
  found = 1L

  return, id
end


pro mg_nc_putdata_putvariable, file_id, variable, data, $
                               dim_names=dim_names, error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return
  endif

  var_ids = ncdf_varidsinq(file_id)
  variable_id = -1L
  if (var_ids[0] ne -1L) then begin
    for v = 0L, n_elements(var_ids) - 1L do begin
      var_info = ncdf_varinq(file_id, var_ids[v])
      if (var_info.name eq variable) then begin
        variable_id = var_ids[v]
        break
      endif
    endfor
  endif

  if (variable_id eq -1L) then begin
    ; create dimensions as needed
    dims = size(data, /dimensions)
    n_dims = size(data, /n_dimensions)
    dim_ids = lonarr(n_dims)

    for i = 0L, n_dims - 1L do begin
      if (i ge n_elements(dim_names)) then begin
        dim_ids[i] = ncdf_dimdef(file_id, $
                                 variable + '_' + strtrim(i, 2), $
                                 dims[i])
      endif else begin
        dim_ids[i] = mg_nc_putdata_checkdimname(file_id, dim_names[i], found=found)
        if (~found) then begin
          dim_ids[i] = ncdf_dimdef(file_id, dim_names[i], dims[i])
        endif
      endelse
    endfor
  
    type = size(data, /type)
    variable_id = ncdf_vardef(file_id, $
                              variable, $
                              dim_ids, $
                              ubyte=type eq 1, $
                              short=type eq 2, $
                              long=type eq 3, $
                              float=type eq 4, $
                              double=type eq 5, $
                              string=type eq 7, $
                              ushort=type eq 12, $
                              ulong=type eq 13)
  endif

  ncdf_varput, file_id, variable_id, data
end


pro mg_nc_putdata_putattribute, file_id, variable, data, error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    error = 1L
    return
  endif

  tokens = strsplit(variable, '.', escape='\', count=ndots)
  dotpos = tokens[ndots - 1L] - 1L
  loc = strmid(variable, 0, dotpos)
  attname = strmid(variable, dotpos + 1L)

  if (loc eq '') then begin
    ncdf_attput, file_id, attname, data, /global
  endif else begin
    var_id = ncdf_varid(file_id, loc)
    ncdf_attput, file_id, var_id, attname, data
  endelse
end


;+
; Routine for writing netCDF files.
;
; :Params:
;   filename : in, required, type=string
;     filename of file to write to; this file does not need to exist beforehand
;   variable : in, required, type=string
;     name of variable to write
;   data : in, required, type=any
;     data to write
;
; :Keywords:
;   dim_names : in, optional, type=strarr
;     string array of dimension names
;   error : out, optional, type=long
;     error code, 0 for no errors
;-
pro mg_nc_putdata, filename, variable, data, dim_names=dim_names, error=error
  compile_opt strictarr

  error = 0L

  ; create an new netCDF file if it doesn't already exist
  if (file_test(filename)) then begin
    file_id = ncdf_open(filename, /write)
  endif else begin
    file_id = ncdf_create(filename, /netcdf4_format)
  endelse

  tokens = strsplit(variable, '.', escape='\', count=ntokens, /preserve_null, /extract)
  ndots = ntokens - 1L

  _variable = ndots eq 0L ? tokens[0] : strjoin(tokens, '.')
  _variable = strpos(_variable, '/') eq 0L ? strmid(_variable, 1) : _variable

  if (ndots eq 0L) then begin
    mg_nc_putdata_putvariable, file_id, _variable, data, $
                               dim_names=dim_names, error=error
    if (error) then message, 'error writing variable', /informational
  endif else begin
    mg_nc_putdata_putattribute, file_id, _variable, data, error=error
    if (error) then message, 'error writing attribute', /informational
  endelse

  ncdf_close, file_id
end


; main-level example program

filename = 'test.nc'

mg_nc_putdata, filename, 'x', findgen(10, 20), error=error
mg_nc_putdata, filename, 'y', dindgen(10), error=error
mg_nc_putdata, filename, 'z', lindgen(10), error=error

help, error

mg_nc_dump, filename

end

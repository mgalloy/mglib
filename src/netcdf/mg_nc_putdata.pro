; docformat = 'rst'

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
;   error : out, optional, type=long
;     error code, 0 for no errors
;-
pro mg_nc_putdata, filename, variable, data, error=error
  compile_opt strictarr

  error = 0L

  ; create an new netCDF file if it doesn't already exist
  if (file_test(filename)) then begin
    file_id = ncdf_open(filename, /write)
  endif else begin
    file_id = ncdf_create(filename, /netcdf4_format)
  endelse

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
    ndims = size(data, /n_dimensions)
    dim_ids = lonarr(ndims)
    dim_names = variable + '_x' + strtrim(sindgen(ndims), 2)
    for d = 0L, ndims - 1L do begin
      dim_ids[d] = ncdf_dimdef(file_id, dim_names[d], /unlimited)
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

; docformat = 'rst'

;+
; Example of using `FILL_VALUE` keyword when creating a netCDF file to set the
; "_FillValue" attribute on a variable.
;
; This example does the equivalent as the following code::
;
;   filename = 'fillvalue_test.nc'
;   file_delete, filename, /allow_nonexistent
;
;   file_id = ncdf_create(filename, /clobber)
;
;   x_id = ncdf_dimdef(file_id, 'x', 10)
;   y_id = ncdf_dimdef(file_id, 'y', 10)
;
;   cmi_id = ncdf_vardef(file_id, 'CMI', [y_id, x_id], /float)
;   ncdf_attput, file_id, cmi_id, '_FillValue', -1.0
;
;   ncdf_control, file_id, /endef
;
;   ncdf_varput, file_id, cmi_id, findgen(10, 10)
;
;   ncdf_close, file_id
;-
pro mg_nc_fillvalue_demo
  compile_opt strictarr

  filename = 'fillvalue_test.nc'
  file_delete, filename, /allow_nonexistent

  mg_nc_putdata, filename, 'CMI', findgen(10, 10), $
                 dim_names=['x', 'y'], $
                 fill_value=-1
end

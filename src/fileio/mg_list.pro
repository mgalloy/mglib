; docformat = 'rst'

;+
; Lists elements of file at given level.
;
; :Returns:
;   `strarr`
;
; :Params:
;   filename : in, required, type=string
;     filename of the file
;   variable : in, required, type=string
;     variable name (with path if inside a group)
;
; :Keywords:
;   count : out, optional, type=integer
;     set to a named variable to get the number of items returned
;   error : out, optional, type=long
;     error value, 0 indicates success
;   _extra : in, optional, type=keywords
;     keywords to appropriate `mg_xx_list` routine
;-
function mg_list, filename, variable, count=count, error=error, _extra=e
  compile_opt strictarr

  case mg_sdf_type(filename) of
    '.grb2': return, mg_grib_list(filename, count=count, error=error, _extra=e)
    ;'.h5': return, mg_h5_list(filename, variable, bounds=bounds, error=error), _extra=e
    '.hdf': return, mg_hdf_list(filename, variable, bounds=bounds, error=error, _extra=e)
    '.nc': return, mg_nc_list(filename, variable, count=count, error=error, _extra=e)
    '.sav': return, mg_save_list(filename, count=count, error=error, /all, _extra=e)
    ;'.xml': return, mg_xml_list(filename, variable, _extra=e)
    else: message, 'unknown file type', /informational
  endcase
end


; main-level example program

nc_filename = file_which('sample.nc')
print, mg_list(nc_filename)

;h5_filename = filepath('hdf5_test.h5', subdir=['examples', 'data'])
;print, mg_list(h5_filename)

end

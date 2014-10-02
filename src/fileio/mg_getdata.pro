; docformat = 'rst'

;+
; Pulls out a section of a variable in a file.
;
; :Examples:
;   Try the main-level example program at the end of this file::
;
;     IDL> .run mg_getdata
;
;   It retrieves data from several different data formats via `MG_GETDATA`::
;
;     nc_filename = file_which('sample.nc')
;     im = mg_getdata(nc_filename, '/image')
;     title = mg_getdata(nc_filename, '/image.TITLE')
;     line = mg_getdata(nc_filename, '/image[*, 256]')
;
;     h5_filename = filepath('hdf5_test.h5', subdir=['examples', 'data'])
;     arr3d = mg_getdata(h5_filename, '/arrays/3D int array[3, 5:*:2, 0:49:3]')
;
; :Returns:
;   data array
;
; :Params:
;   filename : in, required, type=string
;     filename of the file
;   variable : in, required, type=string
;     variable name (with path if inside a group)
;
; :Keywords:
;   bounds : in, optional, type="lonarr(3, ndims) or string"
;     gives start value, end value, and stride for each dimension of the
;     variable
;   error : out, optional, type=long
;     error value
;   _extra : in, optional, type=keywords
;     keywords to appropriate `mg_xx_list` routine
;-
function mg_getdata, filename, variable, bounds=bounds, error=error, record=record, _extra=e
  compile_opt strictarr

  case mg_sdf_type(filename) of
    '.grb2': return, mg_grib_getdata(filename, variable, record=record, error=error, _extra=e)
    '.h5': return, mg_h5_getdata(filename, variable, bounds=bounds, error=error, _extra=e)
    '.hdf': return, mg_hdf_getdata(filename, variable, bounds=bounds, error=error, _extra=e)
    '.nc': return, mg_nc_getdata(filename, variable, bounds=bounds, error=error, _extra=e)
    '.sav': return, mg_save_getdata(filename, variable, bounds=bounds, error=error, _extra=e)
    '.xml': return, mg_xml_getdata(filename, variable, _extra=e)
    else: message, 'unknown file type', /informational
  endcase
end


; main-level example program

nc_filename = file_which('sample.nc')
im = mg_getdata(nc_filename, '/image')
title = mg_getdata(nc_filename, '/image.TITLE')
line = mg_getdata(nc_filename, '/image[*, 256]')

h5_filename = filepath('hdf5_test.h5', subdir=['examples', 'data'])
arr3d = mg_getdata(h5_filename, '/arrays/3D int array[3, 5:*:2, 0:49:3]')

end

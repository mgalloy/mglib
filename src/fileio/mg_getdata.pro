; docformat = 'rst'

;+
; Pulls out a section of a variable in a file.
; 
; :Examples:
;    Try the main-level example program at the end of this file::
;
;       IDL> .run mg_getdata
;
;    It retrieves data from several different data formats via `MG_GETDATA`::
;
;       nc_filename = file_which('sample.nc')
;       im = mg_getdata(nc_filename, '/image')
;       title = mg_getdata(nc_filename, '/image.TITLE')
;       line = mg_getdata(nc_filename, '/image[*, 256]')
;
;       h5_filename = filepath('hdf5_test.h5', subdir=['examples', 'data'])
;       arr3d = mg_getdata(h5_filename, '/arrays/3D int array[3, 5:*:2, 0:49:3]')
;
; :Returns: 
;    data array
;
; :Params:
;    filename : in, required, type=string
;       filename of the file
;    variable : in, required, type=string
;       variable name (with path if inside a group)
;
; :Keywords:
;    bounds : in, optional, type="lonarr(3, ndims) or string"
;       gives start value, end value, and stride for each dimension of the 
;       variable
;    error : out, optional, type=long
;       error value
;-
function mg_getdata, filename, variable, bounds=bounds, error=error
  compile_opt strictarr

  case mg_sdf_type(filename) of
    '.nc': return, mg_nc_getdata(filename, variable, bounds=bounds, error=error)
    '.h5': return, mg_h5_getdata(filename, variable, bounds=bounds, error=error)
    '.hdf': return, mg_hdf_getdata(filename, variable, bounds=bounds, error=error)
    '.sav': return, mg_save_getdata(filename, variable, bounds=bounds, error=error)
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

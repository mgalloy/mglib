; docformat = 'rst'

;+
; Convert an extension to a file format phrase.
; 
; :Private:
; 
; :Params:
;    type : in, required, type=string
;       extension
;-
function mg_dump_typename, type
  compile_opt strictarr
  
  case type of
    '.nc': return, 'netCDF'
    '.h5': return, 'HDF5'
    '.hdf': return, 'HDF'
    '.sav': return, 'save file'
    else: return, ''
  endcase
end


;+
; Determine the data file type and display a simple listing of the contents of 
; the file.
;
; :Params:
;    filename : in, required, type=string
;       file to examine
;
; :Keywords:
;    verbose : in, optional, type=boolean
;       set to display more metadata information about file
;-
pro mg_dump, filename, verbose=verbose
  compile_opt strictarr

  type = mg_sdf_type(filename)
  type_name = mg_dump_typename(type)
  
  if (type ne '') then print, type_name, format='(%"File is of type: %s")'
  
  case type of
    '.nc': mg_nc_dump, filename
    '.h5': mg_h5_dump, filename
    '.hdf': mg_hdf_dump, filename
    '.sav': mg_save_dump, filename, verbose=verbose
    else: message, 'unknown file type', /informational
  endcase
end

; docformat = 'rst'

;+
; Determine if the file is a netCDF file.
;
; :Private:
;
; :Returns:
;    0B or 1B
;
; :Params:
;    filename : in, required, type=string
;       filename to examine
;-
function mg_sdf_type_is_ncdf, filename
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, 0B
  endif

  id = ncdf_open(filename, /nowrite)
  ncdf_close, id

  return, 1B
end


;+
; Determine if the file is a save file.
;
; :Private:
;
; :Returns:
;    0B or 1B
;
; :Params:
;    filename : in, required, type=string
;       filename to examine
;-
function mg_sdf_type_is_save, filename
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, 0B
  endif

  save_file = obj_new('IDL_Savefile', filename)
  obj_destroy, save_file

  return, 1B
end


;+
; Determine the type of scientific data format file given by the filename.
;
; :Returns:
;    string, returns empty string if file format is not found, otherwise
;    returns appropriate extension for file, i.e., `.nc`, `.h5`, `.hdf`, or
;    `.sav`
;
; :Params:
;    filename : in, required, type=string
;       filename to examine
;
; :Keywords:
;    found : out, optional, type=boolean
;       set to a named variable to retrieve whether a format was found for the
;       file
;-
function mg_sdf_type, filename, found=found
  compile_opt strictarr

  found = 1B

  ; check for DAP first
  if (strpos(filename, 'http://') ge 0L || strpos(filename, 'https://') ge 0L) then begin
    is_ncdf = mg_sdf_type_is_ncdf(filename)
    if (is_ncdf) then return, '.nc'
  endif

  ; get extension
  ext =  strmid(filename, strpos(filename, '.', /reverse_search))

  ; test type given by extension, if it matches known extensions
  case ext of
    '.nc': begin
        is_ncdf = mg_sdf_type_is_ncdf(filename)
        if (is_ncdf) then return, ext
      end
    '.h5': begin
        is_h5 = h5f_is_hdf5(filename)
        if (is_h5) then return, ext
      end
    '.hdf': begin
        is_hdf = hdf_ishdf(filename)
        if (is_hdf) then return, ext
      end
    '.sav': begin
        is_save = mg_sdf_type_is_save(filename)
        if (is_save) then return, ext
      end
    else:
  endcase

  ; if not known extension or does not match its extension, try all known
  ; types

  is_ncdf = mg_sdf_type_is_ncdf(filename)
  if (is_ncdf) then return, '.nc'

  is_h5 = h5f_is_hdf5(filename)
  if (is_h5) then return, '.h5'

  is_hdf = hdf_ishdf(filename)
  if (is_hdf) then return, '.hdf'

  is_save = mg_sdf_type_is_save(filename)
  if (is_save) then return, '.sav'

  found = 0B
  return, ''
end


; main-level example program

files = file_search(filepath('', subdir=['examples', 'data']), $
                    '*', $
                    count=count)

for f = 0L, n_elements(files) - 1L do begin
  type = mg_sdf_type(files[f])
  print, files[f], type eq '' ? 'unknown type' : type, $
         format='(%"%s: type = %s")'
endfor

end

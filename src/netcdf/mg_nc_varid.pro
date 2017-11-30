; docformat = 'rst'

;+
; Wrapper around `NCDF_VARID` which doesn't print a message to the output log.
;
; :Returns:
;   long, -1 if not found
;
; :Params:
;   unit : in, required, type=long
;     netCDF identifier
;   name : in, required, type=string
;     variable name
;-
function mg_nc_varid, unit, name
  compile_opt strictarr

  old_quiet = !quiet
  !quiet = 1
  id = ncdf_varid(unit, name)
  !quiet = old_quiet

  return, id
end

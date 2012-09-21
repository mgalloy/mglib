; docformat = 'rst'

;+
; Dumps the structure of an netCDF file to the output log. This routine does
; not read any data, it simply finds the names and datatypes of variables
; and groups.
;
; :Categories: 
;    file i/o, netcdf, sdf
;
; :Examples:
;    See the attached main-level program for a simple example::
; 
;       IDL> .run mg_nc_dump
;
; :Author:
;    Michael Galloy
;-


;+
; Parse and display a simple hierarchy of contents of a netCDF file.
;
; :Params:
;    filename : in, required, type=string
;       netCDF file to parse
;-
pro mg_nc_dump, filename
  compile_opt strictarr
  on_error, 2
  
  f = obj_new('MGffNCFile', filename=filename)
  print, f->dump()
  obj_destroy, f
end


; main-level example program

sample_filename = file_which('sample.nc')
print, sample_filename, format='(%"Output for: %s")'
print, string(bytarr(strlen(sample_filename) + 12L) + (byte('-'))[0])
mg_nc_dump, sample_filename

print

ncgroup_filename = file_which('ncgroup.nc')
print, ncgroup_filename, format='(%"Output for: %s")'
print, string(bytarr(strlen(ncgroup_filename) + 12L) + (byte('-'))[0])
mg_nc_dump, ncgroup_filename

end

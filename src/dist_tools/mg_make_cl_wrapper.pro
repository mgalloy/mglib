; docformat = 'rst'

;+
; Create a UNIX wrapper script to call an IDL routine.
;
; :Params:
;    app_name : in, required, type=string
;       name of routine to call
;    script_name : in, optional, type=string
;       basename of wrapper script
;
; :Keywords:
;    location : in, optional, type=string
;       directory to place the wrapper script
;-
pro mg_make_cl_wrapper, app_name, script_name, location=location
  compile_opt strictarr
  
  ; put script in current directory if location is not specified
  if (n_elements(location) gt 0L) then begin
    _location = location
  endif else begin
    cd, current=current
    _location = current
  endelse
  
  _script_name = n_elements(script_name) eq 0L ? app_name : script_name
  
  filename = filepath(_script_name, root=_location)

  ; write output
  openw, lun, filename, /get_lun
  printf, lun, '#!/bin/sh'
  printf, lun, 'idl -quiet -e ' + app_name +' -args $@'
  free_lun, lun
  
  ; make executable
  file_chmod, filename, /a_execute
end

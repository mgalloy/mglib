; docformat = 'rst'

;+
; Make a zip file from an array of input files. Note that the original files are
; deleted.
;
; :Params:
;   zipfile : in, required, type=string
;     filename for created zipfile
;   files_array
;     filenames to place in zip file; original files are deleted
;
; :Keywords:
;   error : out, optional, type=integer
;     error code from creating zip file, 1 for success and 0 for failure
;-
pro mg_make_zipfile, zipfile, files_array, error=error
  compile_opt strictarr

  ; get undocumented IDLitWriteKML class compiled
  void = { IDLitWriteKML }

  error = IDLKML_SaveKMZ(zipfile, files_array)
end

; docformat = 'rst'

;+
; Wrapper to create a file object.
;
; :Returns:
;    `MGffFile` object/strarr
;
; :Params:
;    filename : in, required, type=string
;       filename of the file
;
; :Keywords:
;    readf : in, optional, type=boolean
;       set to return the contents of file as a string array instead of 
;       returning the file object
;-
function mg_file, filename, readf=readf
  compile_opt strictarr
  
  f = obj_new('MGffFile', filename)
  
  if (keyword_set(readf)) then begin
    lines = f->readf()
    obj_destroy, f
    return, lines
  endif
  
  return, f
end

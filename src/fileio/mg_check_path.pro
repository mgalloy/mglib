; docformat = 'rst'

;+
; Check a file path to see if it exists. If not, then can determine which
; portion of the path is incorrect.
;
; :Examples:
;   Try the main-level example program at the end of this file with::
;
;     IDL> .run mg_check_path
;     Path: /Applications/exelis/idl82/lib/unknown_dir/unknown_file.dat
;     Problem: /Applications/exelis/idl82/lib/unknown_dir
;
;   The example program does::
;
;     IDL> path = filepath('unknown_file.dat', subdir=['lib', 'unknown_dir'])
;     IDL> print, path, format='(%"Path: %s")'
;     Path: /Applications/exelis/idl82/lib/unknown_dir/unknown_file.dat
;     IDL> found = mg_check_path(path, error_path=ppath)
;     IDL> if (~found) then print, ppath, format='(%"Problem: %s")'
;     Problem: /Applications/exelis/idl82/lib/unknown_dir
;
; :Returns:
;   1 if filepath exists, 0 if not
;
; :Params:
;   string filepath
;
; :Keywords:
;   error_path : out, optional, type=string
;     set to a named variable to return the portion of the path which first is
;     is incorrect
;-
function mg_check_path, path, error_path=error_path
  compile_opt strictarr

  result = file_test(path)
  if (~result) then begin
    tokens = strsplit(path, path_sep(), /extract, count=ntokens, /preserve_null)
    for t = 1L, ntokens - 1L do begin
      error_path = strjoin(tokens[0:t], path_sep())
      if (~file_test(error_path)) then break
    endfor
  endif

  return, result
end


; main-level example program

path = filepath('unknown_file.dat', subdir=['lib', 'unknown_dir'])
print, path, format='(%"Path: %s")'
found = mg_check_path(path, error_path=ppath)
if (~found) then print, ppath, format='(%"Problem: %s")'

end

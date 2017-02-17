; docformat = 'rst'

;+
; Wrapper around `FILE_MKDIR` which passes an error state back.
;
; :Params:
;   dir : in, required, type=string/strarr
;     directory or array of directories to create
;
; :Keywords:
;   noexpand_path : in, optional, type=boolean
;     set to use `dir` exactly as passed in
;   error : out, optional, type=long
;     set to a named variable to retrieve the error state of creating the
;     directory, 0 indicates success
;-
pro mg_mkdir, dir, noexpand_path=noexpand_path, error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return
  endif
  
  file_mkdir, dir, noexpand_path=noexpand_path
end

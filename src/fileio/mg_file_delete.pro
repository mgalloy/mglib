; docformat = 'rst'

;+
; Wrapper for `FILE_DELETE` which catches errors and returns status.
;
; :Params:
;   file : in, required, type=string/strarr
;     filename or array of filenames to delete
;
; :Keywords:
;   status : out, optional, type=long
;     set to a named variable to retrieve the status of the file deletion
;     operation, 0 for no error
;   message : out, optional, type=string
;     set to a named variable to retrieve the error message if `STATUS` is not 0
;   _extra : in, optional, type=keywords
;     keywords to `FILE_DELETE`
;-
pro mg_file_delete, file, status=status, message=message, _extra=extra
  compile_opt strictarr

  message = ''
  catch, status
  if (status ne 0L) then begin
    catch, /cancel
    message = !error_state.msg
    return
  endif

  file_delete, file, _extra=e
end

; docformat = 'rst'

;+
; Returns the absolute directory name (with a trailing slash) of the location
; of the source code for the routine that called this function. Returns the
; the current working directory (./) if called from the command line.
;
; :Requires:
;    IDL 6.2
;
; :Returns:
;    string
;
; :Keywords:
;   filename : in, optional, type=boolean
;     set to return the filename of the calling routine, returns empty string if
;     called from the command line
;   routine : in, optional, type=boolean
;     set to return the routine name of the calling routine, returns "$MAIN$" if
;     called from the command line
;-
function mg_src_root, filename=filename, routine=routine
  compile_opt strictarr

  traceback = scope_traceback(/structure)
  calling_frame = traceback[n_elements(traceback) - 2L > 0]
  if (keyword_set(routine)) then return, calling_frame.routine
  return, keyword_set(filename) $
            ? calling_frame.filename $
            : file_dirname(calling_frame.filename, /mark_directory)
end

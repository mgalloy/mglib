; docformat = 'rst'

;+
; Returns the directory name (with a trailing slash) of the location of the
; source code for the routine that called this function. Returns ./ or .\ 
; (depending on platform) if called from the main-level.
;
; :Examples:
;    The location of this file can be determined as in the main-level example
;    program and test routine found at the end of this file. To run it, type::
;
;       IDL> .run vis_src_root
;
;    The example defines a routine VIS_SRC_ROOT_TEST which calls VIS_SRC_ROOT
;    to determine its location::
;
;       pro vis_src_root_test
;         compile_opt strictarr
;  
;         print, vis_src_root()
;       end
;
; :Requires:
;    IDL 5.5
;
; :Returns: 
;    string
;-     
function vis_src_root
  compile_opt strictarr
  
  ; handle finding source root prior to IDL 6.2
  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    
    help, /traceback, output=output
    
    tokens = strsplit(output[1], /extract, count=count)
    if (count lt 4L) then return, '.' + path_sep()
    
    filename = tokens[3]
    dirpos = strpos(filename, path_sep(), /reverse_search)
    return, strmid(filename, 0L, dirpos + 1L)
  endif

  traceback = scope_traceback(/structure)
  callingFrame = traceback[n_elements(traceback) - 2L > 0L]
  return, file_dirname(callingFrame.filename, /mark_directory)
end


; example program

pro vis_src_root_test
  compile_opt strictarr
  
  print, vis_src_root()
end

vis_src_root_test

end
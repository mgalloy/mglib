; docformat = 'rst'

;+
; Wrapper for `MAKE_DLL` that handles input and output directories more
; intelligently.
;
; :Params:
;    cfile : in, required, type=string
;       C filename to create DLL from
;
; :Keywords:
;    _extra : in, optional, type=keywords
;       keywords to MAKE_DLL
;-
pro mg_make_dll, cfile, _extra=e
  compile_opt strictarr
 
  srcdir = file_dirname(file_expand_path(cfile))
  
  if (mg_idlversion(require='7.1')) then begin
    make_dll, file_basename(cfile, '.c'), 'IDL_Load', $
              input_directory=srcdir, $
              output_directory=srcdir, $
              /platform_extension, $
              _extra=e
  endif else begin
    make_dll, file_basename(cfile, '.c'), 'IDL_Load', $
              input_directory=srcdir, $
              output_directory=srcdir, $
              _extra=e
  endelse
end
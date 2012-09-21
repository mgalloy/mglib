; docformat = 'rst'

;+
; Wrapper for MAKE_DLL that handles input and output directories more
; intelligently.
;
; :Requires:
;    IDL 7.1
;
; :Params:
;    cfile : in, required, type=string
;       C filename to create DLL from
;
; :Keywords:
;    _extra : in, optional, type=keywords
;       keywords to MAKE_DLL
;-
pro vis_make_dll, cfile, _extra=e
  compile_opt strictarr
 
  srcdir = file_dirname(file_expand_path(cfile))
  make_dll, file_basename(cfile, '.c'), 'IDL_Load', $
            input_directory=srcdir, $
            output_directory=srcdir, $
            /platform_extension, $
            _extra=e
end
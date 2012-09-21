; docformat = 'rst'

;+
; Build the `cmdline_tools` DLM.
;
; :Keywords:
;    _extra : in, optional, type=keywords
;       keywords to `MG_MAKE_DLL`
;-
pro mg_build_cmdline_tools, _extra=e
  compile_opt strictarr
  
  mg_make_dll, filepath('cmdline_tools.c', root=mg_src_root(), _extra=e)
end

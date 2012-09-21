; docformat = 'rst'

;+
; Build the `dist_tools` DLM.
;-
pro mg_build_dist_tools
  compile_opt strictarr
  
  mg_make_dll, filepath('dist_tools.c', root=mg_src_root())
end
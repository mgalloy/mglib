; docformat = 'rst'

;+
; Build the lineplots DLM.
;-
pro mg_build_lineplots
  compile_opt strictarr
  
  mg_make_dll, filepath('mg_lineplots.c', root=mg_src_root())
end
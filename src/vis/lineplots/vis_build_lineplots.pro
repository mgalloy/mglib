; docformat = 'rst'

;+
; Build the lineplots DLM.
;-
pro vis_build_lineplots
  compile_opt strictarr
  
  vis_make_dll, filepath('vis_lineplots.c', root=vis_src_root())
end
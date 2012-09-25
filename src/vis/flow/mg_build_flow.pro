; docformat = 'rst'

;+
; Build the flow DLM.
;-
pro vis_build_flow
  compile_opt strictarr
  
  vis_make_dll, filepath('vis_flow.c', root=vis_src_root())
end
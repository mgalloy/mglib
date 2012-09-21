; docformat = 'rst'

;+
; Build the mg_net DLM.
;-
pro mg_build_net
  compile_opt strictarr
  
  mg_make_dll, filepath('mg_net.c', root=mg_src_root())
end

; docformat = 'rst'

;+
; Build the flow DLM.
;-
pro mg_build_flow, _extra=e
  compile_opt strictarr
  
  mg_make_dll, filepath('mg_flow.c', root=mg_src_root(), _extra=e)
end

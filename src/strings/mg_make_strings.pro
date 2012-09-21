; docformat = 'rst'


;+
; Build mg_strings.*.so file.
;-
pro mg_make_strings
  compile_opt strictarr
  
  root = mg_src_root()
  mg_make_dll, filepath('mg_strings', root=root), $
               /show_all_output, $
               extra_cflags='-I"/usr/local/include"', $
               extra_lflags='-L/usr/local/lib/ -ltre'
end

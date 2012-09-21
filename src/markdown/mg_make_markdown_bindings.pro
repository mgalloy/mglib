; docformat = 'rst'


;+
; Build `mg_markdown.*.so` file.
;
; The markdown DLM uses David Parsons' DISCOUNT implementation of John 
; Gruber's Markdown markup language. Is is released under a BSD-style license.
;
; :Examples:
;    For an example of using `MG_MARKDOWN`, try::
;
;       IDL> print, mg_markdown('Build the `mg_markdown.*.so` file.')
;       <p>Build the <code>mg_markdown.*.so</code> file.</p>
;-
pro mg_make_markdown_bindings
  compile_opt strictarr
  
  root = mg_src_root()
  mg_make_dll, filepath('mg_markdown', root=root), /show_all_output, $
               extra_cflags='-I"/usr/local/include"', $
               extra_lflags='/usr/local/lib/libmarkdown.a'
end


; main-level example program

print, mg_markdown('Build the `mg_markdown.*.so` file.')

end
; docformat = 'rst'

;+
; Make the documentation for the library.
;-
pro mg_doc_library
  compile_opt strictarr
  
  root = mg_src_root()   ; location of this file

  idldoc, root=filepath('src', root=root), $
          output=filepath('api-docs', root=root), $
          overview=filepath('overview.txt', root=root), $
          footer=filepath('footer.html', root=root), $
          title='idllib', $
          subtitle='Personal IDL library for M. Galloy', $
          /statistics, /embed, index_level=1, format_style='rst', /use_latex
end

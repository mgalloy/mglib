; docformat = 'rst'

;+
; Make the developer API documentation for the library.
;-
pro mg_doc_library
  compile_opt strictarr
  
  args = command_line_args(count=nargs)

  root = nargs gt 1L ? args[0] : mg_src_root()   ; location of this file

  idldoc, root=filepath('src', root=root), $
          output=filepath('api-docs', root='.'), $
          overview=filepath('overview.txt', root=root), $
          footer=filepath('footer.html', root=root), $
          title='mglib', $
          subtitle='Personal IDL library for M. Galloy', $
          /statistics, /embed, index_level=1, format_style='rst', /use_latex, $
          /nosource
end

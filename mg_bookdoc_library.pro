; docformat = 'rst'

;+
; Make the user API documentation for the library in LaTeX format.
;-
pro mg_bookdoc_library
  compile_opt strictarr

  args = command_line_args(count=nargs)

  root = nargs gt 1L ? args[0] : mg_src_root()   ; location of this file

  idldoc, root=filepath('src', root=root), $
          output=filepath('api-bookdocs', root='.'), $
          /user, $
          overview=filepath('overview.txt', root=root), $
          footer=filepath('footer.html', root=root), $
          title='mglib', $
          subtitle='Personal IDL library for M. Galloy', $
          /embed, index_level=1, format_style='rst', $
          /nosource, $
          template_prefix='latex-', $
          comment_style='latex'
end

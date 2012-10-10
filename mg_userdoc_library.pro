; docformat = 'rst'

;+
; Make the user API documentation for the library.
;-
pro mg_userdoc_library
  compile_opt strictarr
  
  root = mg_src_root()   ; location of this file

  idldoc, root=filepath('src', root=root), $
          output=filepath('api-userdocs', root=root), $
          /user, $
          overview=filepath('overview.txt', root=root), $
          footer=filepath('footer.html', root=root), $
          title='mglib', $
          subtitle='Personal IDL library for M. Galloy', $
          /embed, index_level=1, format_style='rst', /use_latex
end

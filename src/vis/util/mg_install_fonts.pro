; docformat = 'rst'

;+
; Install the special fonts with mglib. Need to run this script with
; administrator privileges if the IDL distribution is installed the standard
; locations.
;-
pro mg_install_fonts
  compile_opt strictarr

  root = mg_src_root()
  mg_fonts, install={ mg_fonts_tt, $
                      name: 'Humor Sans', $
                      filename: filepath('Humor-Sans.ttf', root=root), $
                      direct_size: 0.625, $
                      object_size: 1.0 }
end

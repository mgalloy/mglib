; docformat = 'rst'

;+
; Create a new color table file suitable for use with `MODIFYCT`, `LOADCT`,
; `XLOADCT`, and `IDLgrPalette::loadCT`.
;
; :Examples:
;    To create a new color table file, use `MG_CREATE_CTFILE` to create the
;    new file and `MODIFYCT` to add color tables to it. For example::
;
;       IDL> mg_create_ctfile, 'test.tbl'
;       IDL> modifyct, 0, 'CT 0', r0, g0, b0, file='test.tbl'
;       IDL> modifyct, 1, 'CT 1', r1, g1, b1, file='test.tbl'
;       ...etc...
;
; :Params:
;    filename : in, required, type=string
;       filename for new color table file
;-
pro mg_create_ctfile, filename
  compile_opt strictarr

  openw, lun, filename, /get_lun

  writeu, lun, 1B
  writeu, lun, bytarr(3 * 256)
  writeu, lun, bytarr(32) + 32B

  free_lun, lun
end

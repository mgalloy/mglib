; docformat = 'rst'

;+
; Create a PNG byte stream of a 2- or 3-dimensional image.
;
; :Returns:
;    bytarr
;
; :Params:
;    im : in, required, type=bytarr
;       2- or 3-dimensional image
;    r : in, optional, type=bytarr(256)
;       the red component of any colors in a associated color table
;    g : in, optional, type=bytarr(256)
;       the green component of any colors in a associated color table
;    b : in, optional, type=bytarr(256)
;       the blue component of any colors in a associated color table
;
; :Keywords:
;    _extra : in, optional, type=keywords
;       keywords to WRITE_PNG
;-
function mg_encode_png, im, r, g, b, _extra=e
  compile_opt strictarr

  ; get a unique filename
  filename = mg_temp_filename('mg_encode_png-%s.png')

  ; write a PNG file
  write_png, filename, im, r, g, b, _extra=e

  ; read back PNG file as a byte stream
  info = file_info(filename)
  stream = bytarr(info.size)
  openr, lun, filename, /get_lun
  readu, lun, stream
  free_lun, lun

  ; cleanup
  file_delete, filename, /quiet

  return, stream
end

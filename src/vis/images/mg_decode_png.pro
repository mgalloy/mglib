; docformat = 'rst'

;+
; Decodes a PNG byte stream to a 2- or 3-dimensional image array.
;
; :Returns:
;    2- or 3-dimensional image array
;
; :Params:
;    stream : in, required, type=bytarr
;       PNG byte stream
;    r : out, optional, type=bytarr(256)
;       set to a named variable to get the red component of any colors in a
;       associated color table
;    g : out, optional, type=bytarr(256)
;       set to a named variable to get the green component of any colors in a
;       associated color table
;    b : out, optional, type=bytarr(256)
;       set to a named variable to get the blue component of any colors in a
;       associated color table
;
; :Keywords:
;    _ref_extra : in, out, optional, type=keywords
;       keywords to READ_PNG
;-
function mg_decode_png, stream, r, g, b, _ref_extra=e
  compile_opt strictarr

  ; get a unique filename
  filename = mg_temp_filename('mg_decode_png-%s.png')

  ; write im as a stream of bytes
  openw, lun, filename, /get_lun
  writeu, lun, stream
  free_lun, lun

  ; read back in as a PNG
  im = read_png(filename, r, g, b, _extra=e)

  ; cleanup
  file_delete, filename, /quiet

  return, im
end
; docformat = 'rst'

;+
; Base64 encode a byte-valued array, splitting it into rows of `column_size`
; characters delimited by the platform newline characters.
;
; :Returns:
;   string
;
; :Params:
;   im : in, required, type=bytarr
;     byte array to encode
;
; :Keywords:
;   column_size : in, optional, type=long, default=76
;     size of rows to break output into
;   encoded : in, optional, type=boolean
;     set to indicate `im` is already in encoded in png or some other format
;-
function mg_base64_image, im, column_size=column_size, encoded=encoded
  compile_opt strictarr

  _column_size = n_elements(column_size) eq 0L ? 76L : column_size

  s = idl_base64(keyword_set(encoded) ? im : mg_encode_png(im))

  n = strlen(s)
  if (n mod _column_size ne 0L) then begin
    padding = _column_size - n mod _column_size
    b = [byte(s), bytarr(padding)]
  endif else begin
    padding = 0L
    b = byte(s)
  endelse

  b = reform(temporary(b), _column_size, (n + padding) / _column_size)

  return, mg_strmerge(string(b))
end


; main-level example program

im = read_image(filepath('mineral.png', subdir=['examples', 'data']))
str = mg_base64_image(im)
html = '<html><body><img src="data:image/png;base64,' + str + '"/></body></html>'

openw, lun, 'mineral.html', /get_lun
printf, lun, html
free_lun, lun

end

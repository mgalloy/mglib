; docformat = 'rst'

;+
; Compress a byte array.
;
; :Returns:
;   `bytarr`
;
; :Params:
;   barr : in, required, type=bytarr
;     data to be compressed
;
; :Keywords:
;   n_bytes : out, optional, type=long
;     number of bytes in compressed byte array
;-
function mg_compress, barr, n_bytes=n_bytes
  compile_opt strictarr, hidden

  tmp_filename = filepath('compressed_file', /tmp)
  openw, lun, tmp_filename, /get_lun, /compress
  writeu, lun, barr
  free_lun, lun

  n_bytes = (file_info(tmp_filename)).size
  comp_barr = bytarr(n_bytes)

  openr, lun, tmp_filename, /get_lun, /delete
  readu, lun, comp_barr
  free_lun, lun

  return, comp_barr
end
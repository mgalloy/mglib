; docformat = 'rst'

;+
; Returns size of file in bytes.
;
; :Returns:
;   long
;
; :Params:
;   filename : in, required, type=string
;     filename of file to check
;-
function mg_filesize, filename
  compile_opt strictarr

  finfo = file_info(filename)
  return, finfo.size
end

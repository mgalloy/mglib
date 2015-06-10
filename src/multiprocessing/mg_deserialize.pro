; docformat = 'rst'

;+
; Deserialize a string to the original variable.
;
; :Returns:
;   array, structure, or object corresponding to original variable
;
; :Params:
;   str : in, required, type=string
;     serialization of variable as obtained from `MG_SERIALIZE`
;
; :Requires:
;   IDL 8.2
;-
function mg_deserialize, str
  compile_opt strictarr

  bytes = idl_base64(str)

  typecode = ulong(bytes[0])
  dims = ulong64(bytes[1:64], 0, 8)
  dims = dims[where(dims ne 0, /null)]
  bytes = bytes[65:*]

  ; structures (8) and objects (11) are handled differently
  if (typecode eq 8 || typecode eq 11) then begin
    tempfile = mg_temp_filename('mg_serialize-%s.sav')
    openw, lun, tempfile, /get_lun
    writeu, lun, zlib_uncompress(bytes, type=1)
    free_lun, lun
    restore, tempfile
    file_delete, tempfile
    return, var
  endif else begin
    return, zlib_uncompress(bytes, dimensions=dims, type=typecode)
  endelse
end

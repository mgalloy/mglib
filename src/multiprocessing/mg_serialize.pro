; docformat = 'rst'

;+
; Serializes an array, object, or structure to a string.
;
; :Returns:
;   string
;
; :Params:
;   var : in, required, type=array/object/structure
;     variable to serialize
;
; :Requires:
;   IDL 8.2
;-
function mg_serialize, var
  compile_opt strictarr

  typecode = byte(size(var, /type))
  dims = ulon64arr(8)
  dims[0] = size(var, /dimensions)

  ; structures (8) and objects (11) are handled differently
  if (typecode eq 8 || typecode eq 11) then begin
    tempfile = mg_temp_filename('mg_serialize-%s.sav')
    save, var, /compress, filename=tempfile
    b = read_binary(tempfile, datatype=1)
    file_delete, tempfile
    bytes = zlib_compress(b)
  endif else begin
    bytes = zlib_compress(var)
  endelse

  ; tack on dims and type to the beginning of every serialization byte stream
  bytes = [typecode, byte(dims, 0, 64), bytes]

  return, idl_base64(bytes)
end


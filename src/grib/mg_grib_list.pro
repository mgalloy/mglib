; docformat = 'rst'

;+
; Return array of keys in a record.
;
; :Returns:
;   `strarr` or `!null` if none found
;
; :Params:
;   filename : in, required, type=string
;     filename of the netCDF file
;
; :Keywords:
;   record : in, optional, type=integer, default=1
;     record to grab keys from
;   count : out, optional, type=integer
;     set to a named variable to get the number of items returned
;   error : out, optional, type=long
;     error value, 0 indicates success
;-
function mg_grib_list, filename, record=record, count=count, error=error
  compile_opt strictarr

  error = 0L

  _record = n_elements(record) eq 0L ? 1L : record

  file = grib_open(filename)
  ghandle = grib_new_from_file(file)

  ; advance to correct record
  r = 1
  while (r ne _record) do begin
    grib_release, ghandle
    ghandle = grib_new_from_file(file)
    r++
  endwhile

  keys = list()

  ; iterator through keys
  iterator = grib_keys_iterator_new(ghandle, /all)
  while grib_keys_iterator_next(iterator) do begin
    keys->add, grib_keys_iterator_get_name(iterator)
  endwhile
  grib_keys_iterator_delete, iterator

  count = keys->count()
  result = keys->toArray()
  obj_destroy, keys

  grib_release, ghandle
  grib_close, file

  return, result
end


; main-level example program

root = mg_src_root()
filename = filepath('atl.grb2', $
                    subdir=['..', '..', 'unit', 'grib_ut'], $
                    root=root)
keys = mg_grib_list(filename, record=2)
help, keys

end

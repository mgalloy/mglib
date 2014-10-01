; docformat = 'rst'

;= Main routine

;+
; Pulls out a section of a GRIB variable.
;
; :Returns:
;   data
;
; :Params:
;   filename : in, required, type=string
;     filename of the GRIB file
;   key : in, required, type=string
;     key name
;
; :Keywords:
;   record : in, optional, type=integer, default=1
;     record number
;   error : out, optional, type=long
;     error value
;-
function mg_grib_getdata, filename, key, record=record, error=error
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

  nel = grib_get_size(ghandle, key)
  result = nel eq 1L ? grib_get(ghandle, key) : grib_get_array(ghandle, key)

  grib_release, ghandle
  grib_close, file

  return, result
end


; main-level example

root = mg_src_root()
filename = filepath('atl.grb2', $
                    subdir=['..', '..', 'unit', 'grib_ut'], $
                    root=root)

for r = 1, grib_count(filename) do begin
  keys = ['kurtosis', 'skewness']
  foreach key, keys do begin
    print, key, mg_grib_getdata(filename, key, record=r), format='(%"%s: %0.3g")'
  endforeach
endfor

end

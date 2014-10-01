; docformat = 'rst'

;+
; Dumps the structure of an GRIB file to the output log. This routine does
; not read any data, it simply finds the names and datatypes of variables.
;
; :Categories:
;   file i/o, grib, sdf
;
; :Examples:
;   See the attached main-level program for a simple example::
;
;     IDL> .run mg_grib_dump
;
; :Author:
;   Michael Galloy
;-



function mg_grib_dump_type, ghandle, key_name
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, '-'
  endif

  nel = grib_get_size(ghandle, key_name)
  if (nel eq 1L) then begin
    type_code = grib_get_native_type(ghandle, key_name)
    return, string(strtrim(grib_get(ghandle, key_name), 2), $
                   mg_grib_typedecl(type_code, /suffix), $
                   format='(%"%s%s")')
  endif else begin
    type_code = grib_get_native_type(ghandle, key_name)
    return, string(mg_grib_typedecl(type_code), nel, format='(%"%s(%d)")')
  endelse
end


;+
; Parse and display a simple hierarchy of contents of a GRIB file.
;
; :Params:
;   filename : in, required, type=string
;     GRIB file to parse
;-
pro mg_grib_dump, filename
  compile_opt strictarr

  file = grib_open(filename)

  print, file_expand_path(filename), format='(%"+ FILE <%s>")'

  for r = 1, grib_count(filename) do begin
    ghandle = grib_new_from_file(file)
    iterator = grib_keys_iterator_new(ghandle, /all)
    while grib_keys_iterator_next(iterator) do begin
      key_name = grib_keys_iterator_get_name(iterator)
      print, r, key_name, mg_grib_dump_type(ghandle, key_name), $
             format='(%"  - RECORD %d KEY %s: %s")'
    endwhile
    grib_keys_iterator_delete, iterator

    grib_release, ghandle
  endfor

  grib_close, file
end


; main-level example

root = mg_src_root()
filename = filepath('atl.grb2', $
                    subdir=['..', '..', 'unit', 'grib_ut'], $
                    root=root)

mg_grib_dump, filename

end
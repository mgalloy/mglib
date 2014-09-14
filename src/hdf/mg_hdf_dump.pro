; docformat = 'rst'

;+
; Dumps contents of an HDF file. Currently only finds SD datasets and their
; attributes.
;-


;+
; Convert a type string and dimensions array into a string description of the
; variable, e.g., `FLOAT[256, 256]`.
;
; :Private:
;
; :Returns:
;   string
;
; :Params:
;   type : in, required, type=string
;     string returned from HDF API describing type
;   dims : in, required, type=lonarr
;     dimensions of variable
;-
function mg_hdf_dump_typedecl, type, dims
  compile_opt strictarr

  return, string(type, strjoin(strtrim(dims, 2), ', '), format='(%"%s[%s]")')
end


;+
; Dump the AN contents of an HDF file.
;
; :Private:
;
; :Params:
;   file_id : in, required, type=long
;     file HDF identifier
;-
pro mg_hdf_dump_an, file_id
  compile_opt strictarr

  an_id = hdf_an_start(file_id)
  status = hdf_an_fileinfo(an_id, nFileLabels, nFileDescs, nDataLabels, nDataDescs)
  help, nFileLabels, nFileDescs, nDataLabels, nDataDescs
  for fl = 0L, nFileLabels - 1L do begin
    id = hdf_an_select(an_id, fl, 2)
    status = hdf_an_readann(id, annotation)
    help, annotation
  endfor

  hdf_an_end, an_id
end


;+
; Dump the SD contents of an HDF file.
;
; :Private:
;
; :Params:
;   file_id : in, required, type=long
;     file HDF identifier
;-
pro mg_hdf_dump_sd, file_id
  compile_opt strictarr

  hdf_sd_fileinfo, file_id, ndatasets, nattributes

  ; global attributes
  for a = 0L, nattributes - 1L do begin
    hdf_sd_attrinfo, file_id, a, name=attname, count=count, type=atttype
    atttypedecl = mg_hdf_dump_typedecl(atttype, count)
    print, '', atttypedecl, attname, format='(%"%sATTRIBUTE %s %s")'
  endfor

  for d = 0L, ndatasets - 1L do begin
    sds_id = hdf_sd_select(file_id, d)
    hdf_sd_getinfo, sds_id, name=name, natts=natts, type=type, dims=dims
    typedecl = mg_hdf_dump_typedecl(type, dims)
    print, typedecl, name, format='(%"SD DATASET %s %s")'
    for a = 0L, natts - 1L do begin
      hdf_sd_attrinfo, sds_id, a, name=attname, count=count, type=atttype
      atttypedecl = mg_hdf_dump_typedecl(atttype, count)
      print, '  ', atttypedecl, attname, format='(%"%sATTRIBUTE %s %s")'
    endfor
  endfor
end


;+
; Dump contents of given HDF file.
;
; :Bugs:
;   limited to SD contents right now
;
; :Params:
;   filename : in, required, type=string
;     filename of file to examine
;-
pro mg_hdf_dump, filename
  compile_opt strictarr

  file_id = hdf_sd_start(expand_path(filename))

  ;mg_hdf_dump_an, file_id
  ; TODO: DF24
  ; TODO: DFAN
  ; TODO: DFP
  ; TODO: DFR8
  ; TODO: GR
  mg_hdf_dump_sd, file_id
  ; TODO: VD
  ; TODO: VG

  hdf_sd_end, file_id
end


; main-level example program

filename = '~/data/modis/MOD021KM.A2010019.1235.005.2010259102219.hdf'
mg_hdf_dump, filename

mg_hdf_dump, filepath('vattr_example.hdf', subdir=['examples', 'data'])

end

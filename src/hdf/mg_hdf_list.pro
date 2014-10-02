; docformat = 'rst'

;+
; Lissts contents of an HDF file. Currently only finds SD datasets and their
; attributes.
;-


;+
; Dump the SD contents of an HDF file.
;
; :Private:
;
; :Params:
;   file_id : in, required, type=long
;     file HDF identifier
;   path : in, required, type=string
;     location of level to list elements of
;   names : in, required, type=list
;     list to add names to
;
; :Keywords:
;   attributes : in, optional, type=boolean
;     set to return attribute names
;   variables : in, optional, type=boolean
;     set to return variable names
;-
pro mg_hdf_list_sd, file_id, path, names, $
                    attributes=attributes, $
                    variables=variables
  compile_opt strictarr

  hdf_sd_fileinfo, file_id, ndatasets, nattributes

  ; global attributes
  if (keyword_set(attributes) && (n_elements(path) eq 0 || path eq '')) then begin
    for a = 0L, nattributes - 1L do begin
      hdf_sd_attrinfo, file_id, a, name=attname, count=count, type=atttype
      names->add, attname
    endfor
  endif

  for d = 0L, ndatasets - 1L do begin
    sds_id = hdf_sd_select(file_id, d)
    hdf_sd_getinfo, sds_id, name=name, natts=natts, type=type, dims=dims
    if (keyword_set(variables) && (n_elements(path) eq 0 || path eq '')) then begin
      names->add, name
    endif
    if (keyword_set(attributes) && (n_elements(path) gt 0 && path eq name)) then begin
      for a = 0L, natts - 1L do begin
        hdf_sd_attrinfo, sds_id, a, name=attname, count=count, type=atttype
        names->add, attname
      endfor
    endif
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
;   path : in, optional, type=string
;     location of level to list elements of
;
; :Keywords:
;   attributes : in, optional, type=boolean
;     set to return attribute names
;   variables : in, optional, type=boolean
;     set to return variable names
;   count : out, optional, type=integer
;     set to a named variable to get the number of items returned
;   error : out, optional, type=long
;     error value, 0 indicates success
;-
function mg_hdf_list, filename, path, $
                      attributes=attributes, $
                      variables=variables, $
                      count=count, error=error
  compile_opt strictarr

  names = list()

  file_id = hdf_sd_start(expand_path(filename))

  ;mg_hdf_dump_an, file_id
  ; TODO: DF24
  ; TODO: DFAN
  ; TODO: DFP
  ; TODO: DFR8
  ; TODO: GR
  mg_hdf_list_sd, file_id, path, names, $
                  attributes=attributes, $
                  variables=variables

  ; TODO: VD
  ; TODO: VG

  hdf_sd_end, file_id

  count = names->count()
  names_array = names->toArray()

  return, names_array
end


; main-level example program

print, mg_hdf_list(filepath('vattr_example.hdf', subdir=['examples', 'data']))

end

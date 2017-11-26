; format = 'rst'

;+
; Convert a structure of arrays to an array of structures. Each field of the
; structure must have the same number of elements.
;
; :Returns:
;   array of structures
;
; :Params:
;   sarr : in, required, type=structure
;     structure containing arrays as fields
;
; :Keywords:
;   field_names : in, optional, type=strarr
;     names of the fields to use instead of the same names as in the original
;     structure
;-
function mg_convert_structarr, sarr, field_names=field_names
  compile_opt strictarr

  tnames = n_elements(field_names) eq 0L ? tag_names(sarr) : field_names

  s = {}
  for t = 0L, n_tags(sarr) - 1L do begin
    s = create_struct(s, tnames[t], (sarr.(t))[0])
  endfor

  output = replicate(s, n_elements(sarr.(0)))
  for t = 0L, n_tags(s) - 1L do output.(t) = sarr.(t)

  return, output
end

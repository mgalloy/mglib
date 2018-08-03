;+
; Convert value to boolean.
;
; :Private:
;
; :Params:
;   value : in, required, type=string/strarr
;     value to convert to booleans
;-
function mg_convert_boolean, value
  compile_opt strictarr

  if (size(value, /n_dimensions) gt 0L) then begin
    n = n_elements(value)
    result = bytarr(n)
    for i = 0L, n - 1L do result[i] = mg_convert_boolean(value[i])
    return, result
  endif

  switch strlowcase(value) of
    '1':
    'yes':
    'true': return, 1B
    else: return, 0B
  endswitch
end

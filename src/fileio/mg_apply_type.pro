; docformat = 'rst'

function mg_apply_type, value, type_code, extract=extract
  compile_opt strictarr
  on_error, 2

  if (keyword_set(extract)) then begin
    _value = strtrim(value, 2)
    if (strmid(_value, 0, 1) eq '[' $
          && strmid(_value, 0, 1, /reverse_offset) eq ']') then begin
      _value = strmid(_value, 1, strlen(_value) - 2)
    endif 
    _value = strtrim(strsplit(_value, ',', /extract), 2)
  endif else _value = value

  if (type_code eq 1) then begin
    return, mg_convert_boolean(_value)
  endif

  return, fix(_value, type=type_code)
end

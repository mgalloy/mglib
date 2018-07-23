; docformat = 'rst'

;= helper methods


function mgffspecoptions::_apply_type, value, type_code, extract=extract
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
    return, self->_convertBoolean(_value)
  endif

  return, fix(_value, type=type_code)
end


function mgffspecoptions::_get_type, name
  compile_opt strictarr
  on_error, 2
  on_ioerror, bad_format

  switch strlowcase(name) of
    '1':
    'bool':
    'boolean': begin
        type = 1
        break
      end
    '3':
    'long': begin
        type = 3
        break
      end
    '4':
    'float': begin
        type = 4
        break
      end
    '7':
    'str':
    'string': begin
        type = 7
        break
      end
    else: begin
        type = long(name)
      end
  endswitch

  return, type

  bad_format:
  message, 'bad type code'
end


;+
; ::
;
;   [logging]
;   log_dir         : type=str
;   level           : type=str, default=DEBUG
;   max_log_version : type=long
;-
pro mgffspecoptions::_parse_spec_line, spec_line, $
                                       type=type, $
                                       extract=extract, $
                                       default=default
  compile_opt strictarr

  type = 7
  default_found = 0B
  extract = 0B
  default = !null

  expressions = strsplit(spec_line, ',', /extract, count=n_expressions)
  last_start = 0L
  for e = 1L, n_expressions - 1L do begin
    if (strpos(expressions[e], '=') ne -1) then begin
      last_start = e
    endif else begin
      expressions[last_start] += ',' + expressions[e]
      expressions[e] = ''
    endelse
  endfor

  expressions = strtrim(expressions[where(expressions ne '')], 2)

  for e = 0L, n_elements(expressions) - 1L do begin
    tokens = strsplit(expressions[e], '=', /extract, count=n_tokens)
    case strlowcase(tokens[0]) of
      'type': type = self->_get_type(tokens[1])
      'default': begin
          default = tokens[1]
          default_found = 1B
        end
      'extract': begin
          extract = self->_convertBoolean(tokens[1])
        end
      else:
    endcase
  endfor

  if (default_found) then default = self->_apply_type(default, $
                                                      type, $
                                                      extract=extract)
end


;= API


;+
; Determine if the options are valid by the specification.
;
; :Returns:
;   1 if valid, 0 if not
;-
function mgffspecoptions::is_valid
  compile_opt strictarr

  ; TODO: implement
  return, 1B
end


;+
; Return value for a given option.
;
; :Returns:
;   string or string array
;
; :Params:
;   option : in, required, type=string
;     option name to retrieve value for
;
; :Keywords:
;   section : in, optional, type=string, default=''
;     section to search for option in
;   found : out, optional, type=boolean
;     set to a named variable to determine if the option is found
;   raw : in, optional, type=boolean
;     set to retrieve value with no processing
;   extract : in, optional, type=boolean
;     set to return an array of the elements in a value that is formatted like::
;
;       [0, 1, 2]
;
;   boolean : in, optional, type=boolean
;     set to convert retrieved values to boolean values, 0B or 1B; accepts 1,
;     "yes", "true" (either case) as true, everything else as false
;   type : in, optional, type=integer
;     type code to convert result to; default is a string
;   count : out, optional, type=long
;     set to a named variable to determine the number of elements returned (most
;     useful when using `EXTRACT`)
;   default : in, optional, type=string
;     default value to return if option is not found
;-
function mgffspecoptions::get, option, $
                               section=section, $
                               found=found, $
                               count=count

  compile_opt strictarr
  ;on_error, 2

  spec_line = self.spec->get(option, section=section, found=found)
  if (found) then begin
    self->_parse_spec_line, spec_line, $
                            type=type, $
                            extract=extract, $
                            default=default
  endif else begin
    type = 7
    extract = 0B
    default = ''
  endelse

  value = self->mgffoptions::get(option, $
                                 section=section, $
                                 type=type, $
                                 extract=extract, $
                                 default=default, $
                                 found=found, $
                                 count=count)
  return, value
end


;= lifecycle methods

pro mgffspecoptions::cleanup
  compile_opt strictarr

  obj_destroy, self.spec
end


function mgffspecoptions::init, spec=spec, _extra=e
  compile_opt strictarr

  if (~self->mgffoptions::init(_extra=e)) then return, 0

  self.spec = mg_read_config(spec)

  return, 1
end


pro mgffspecoptions__define
  compile_opt strictarr

  !null = {MGffSpecOptions, inherits MGffOptions, $
           spec: obj_new()}
end

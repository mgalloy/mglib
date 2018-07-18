; docformat = 'rst'

;= helper methods

function mgffspecoptions::_type_code, name
  compile_opt strictarr

  switch strlowcase(name) of
    'float': begin
        type = 4
        break
      end
    'long': begin
        type = 3
        break
      end
    '7':
    'str':
    'string': begin
        type = 7
        break
      end
    else:
  endswitch

  return, type
end


;+
;   [logging]
;   log_dir         : type=str
;   level           : default=DEBUG, type=str
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

  expressions = strtrim(strsplit(spec_line, ',', $
                                 /extract, $
                                 count=n_expressions), $
                        2)
  for e = 0L, n_expressions - 1L do begin
    tokens = strsplit(expressions[e], '=', /extract, count=n_tokens)
    case strlowcase(tokens[0]) of
      'type': type = self->_type_code(tokens[1])
      'default': begin
          default = tokens[1]
          default_found = 1B
        end
      'extract': extract = 1B
      else:
    endcase
  endfor

  if (default_found) then default = fix(default, type=type)
end


;= API

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
  on_error, 2

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

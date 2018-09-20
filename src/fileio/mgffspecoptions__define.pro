; docformat = 'rst'

;= API


;+
; Determine if the options are valid by the specification.
;
; :Returns:
;   1 if valid, 0 if not
;-
function mgffspecoptions::is_valid, error_msg=error_msg
  compile_opt strictarr

  error_msg = ''

  ; check that every option is in the spec
  self->mgffoptions::getProperty, sections=sections
  for s = 0L, n_elements(sections) - 1L do begin
    if (sections[s] eq 'DEFAULT' || sections[s] eq '') then continue
    options = self->mgffoptions::options(section=sections[s], count=n_options)
    if (n_options gt 0L) then begin
      for o = 0L, n_options - 1L do begin
        spec_line = self.spec->get(options[o], section=sections[s], found=found)
        if (~found) then begin
          error_msg = string(sections[s], options[o], $
                             format='(%"option %s/%s not found in specification")')
          return, 0B
        endif
      endfor
    endif
  endfor

  ; check that every spec without a default is given
  self.spec->getProperty, sections=spec_sections
  for s = 0L, n_elements(spec_sections) - 1L do begin
    spec_options = self.spec->options(section=spec_sections[s], count=n_options)
    for o = 0L, n_options - 1L do begin
      spec_line = self.spec->get(spec_options[o], section=spec_sections[s])
      mg_parse_spec_line, spec_line, $
                          type=type, $
                          extract=extract, $
                          default=default
      if (n_elements(default) eq 0L) then begin
        value = self->mgffoptions::get(spec_options[o], $
                                       section=spec_sections[s], $
                                       found=found)
        if (~found) then begin
          error_msg = string(spec_sections[s], spec_options[o], $
                             format='(%"option %s/%s not found and no default in specification")')
          return, 0B
        endif
      endif
    endfor
  endfor

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
  on_error, 2

  spec_line = self.spec->get(option, section=section, found=found)
  if (found) then begin
    mg_parse_spec_line, spec_line, $
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

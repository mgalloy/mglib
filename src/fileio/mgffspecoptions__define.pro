; docformat = 'rst'

;= helper methods

;+
; Create a string representation of the config file.
;
; :Returns:
;   `strarr`
;
; :Keywords:
;   substitute : in, optional, type=boolean
;     set to perform substitutions
;-
function mgffspecoptions::_toString, substitute=substitute
  compile_opt strictarr

  first_line = 1B
  output_list = list()

  max_width = 0L
  foreach sec, self.sections do begin
    foreach option, sec, o do begin
      max_width >= strlen(o)
    endforeach
  endforeach

  format = string(max_width, format='(%"(\%\"\%-%ds \%s \%s\"\)")')

  if (self.sections->hasKey('')) then begin
    default_sec = (self.sections)['']
    foreach option, default_sec, o do begin
      first_line = 0B
      output_list->add, string(o, self.output_separator, option, format=format)
    endforeach
  endif

  foreach sec, self.sections, s do begin
    if (s eq '') then continue
    if (~first_line) then output_list->add, '' else first_line = 0B

    output_list->add, string(s, format='(%"[%s]")')
    foreach option, sec, o do begin
      option_value = keyword_set(substitute) ? self->get(o, section=s) : option

      if (s ne 'DEFAULT') then begin
        spec_line = self.spec->get(o, section=s)
        mg_parse_spec_line, spec_line, boolean=boolean

        if (keyword_set(boolean)) then begin
          option_value = mg_convert_boolean(option_value) ? 'YES' : 'NO'
        endif
      endif

      option_value = strtrim(option_value, 2)

      output_list->add, string(o, self.output_separator, option_value, format=format)
    endforeach
  endforeach

  output = transpose(output_list->toArray())
  obj_destroy, output_list
  return, output
end


;= API

;+
; Determine if the options are valid by the specification.
;
; :Returns:
;   1 if valid, 0 if not
;
; :Keywords:
;   error_msg : out, optional, type=string
;     set to a named variable to retrieve an error message, empty string if
;     valid
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

  ; check that every spec without a default is given, unless optional
  self.spec->getProperty, sections=spec_sections
  for s = 0L, n_elements(spec_sections) - 1L do begin
    spec_options = self.spec->options(section=spec_sections[s], count=n_options)
    for o = 0L, n_options - 1L do begin
      spec_line = self.spec->get(spec_options[o], section=spec_sections[s])
      mg_parse_spec_line, spec_line, $
                          type=type, $
                          extract=extract, $
                          optional=optional, $
                          default=default
      if (n_elements(default) eq 0L && ~optional) then begin
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
;   count : out, optional, type=long
;     set to a named variable to determine the number of elements returned (most
;     useful when using `EXTRACT`)
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
                        boolean=boolean, $
                        extract=extract, $
                        optional=optional, $
                        default=default
  endif else begin
    if (strlowcase(section) ne 'default') then begin
      message, string(option, section, $
                      format='(%"option=%s, section=%s not found in spec")')
    endif
    type = 7
    extract = 0B
    default = ''
  endelse

  value = self->mgffoptions::get(option, $
                                 section=section, $
                                 type=type, $
                                 boolean=boolean, $
                                 extract=extract, $
                                 default=default, $
                                 found=found, $
                                 count=count)

  return, value
end


;= property access

pro mgffspecoptions::getProperty, spec=spec, _ref_extra=e
  compile_opt strictarr

  if (arg_present(spec)) then spec = self.spec

  if (n_elements(e) gt 0L) then begin
    self->mgffoptions::getProperty, _strict_extra=e
  endif
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

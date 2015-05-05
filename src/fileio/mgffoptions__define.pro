; docformat = 'rst'

;+
; This is the internal storage for configuration file options and their values.
; It is returned by `MG_READ_CONFIG` and can also be used through the `DEFAULTS`
; keyword of `MG_READ_CONFIG` to set defaults before reading a configuration
; file.
;
; :Properties:
;   fold_case
;     set for case-insensitive matching for section and option names.
;   sections
;     array of section names
;
; :Requires:
;   IDL 8.0
;-


;= overload methods


;+
; Overload method to handle accessing options via array indexing notation.
;
; :Examples:
;   For example::
;
;     IDL> config = mgffoptions()
;     IDL> config->put, 'City', 'Boulder', section='Mike'
;     IDL> config->put, 'State', 'Colorado', section='Mike'
;     IDL> config->put, 'City', 'Madison', section='Mark'
;     IDL> config->put, 'State', 'Wisconsin', section='Mark'
;     IDL> print, config['Mike', 'City']
;     Boulder
;
; :Returns:
;   string
;
; :Params:
;   isRange : in, required, type=bytarr
;     unused
;   ss1 : in, required, type=string
;     option name if `ss2` not given, section name if `ss2` given
;   ss2 : in, optional, type=string, default=''
;     option name if present
;-
function mgffoptions::_overloadBracketsRightSide, isRange, ss1, ss2
  compile_opt strictarr

  case n_params() of
    2: begin
        _section = ''
        _option = ss1
      end
    3: begin
        _section = ss1
        _option = ss2
      end
  endcase

  return, self->get(_option, section=_section)
end


;+
; Overload method to handle setting option values using array notation.
;
; :Examples:
;   For example::
;
;     IDL> config = mgffoptions()
;     IDL> config['Mike', 'City'] = 'Boulder'
;     IDL> config['Mike', 'State'] = 'Colorado'
;     IDL> config['Mark', 'City'] = 'Madison'
;     IDL> config['Mark', 'State'] = 'Wisconsin'
;     IDL> print, config
;     [Mark]
;     City:   Madison
;     State:  Wisconsin
;
;     [Mike]
;     City:   Boulder
;     State:  Colorado
;
; :Params:
;   obj : in, required, type=MGffOptions object
;     `MGffOptions` object, should be `self`
;   value : in, required, type=string
;     value from the right-hand side of the expression
;   isRange : in, required, type=bytarr
;     unused
;   ss1 : in, required, type=string
;     option name if `ss2` not given, section name if `ss2` given
;   ss2 : in, optional, type=string, default=''
;     option name if present
;-
pro mgffoptions::_overloadBracketsLeftSide, obj, value, isRange, ss1, ss2
  compile_opt strictarr

  case n_params() of
    4: begin
        _section = ''
        _option = ss1
      end
    5: begin
        _section = ss1
        _option = ss2
      end
  endcase

  self->put, _option, value, section=_section
end


;+
; Loop through sections of a `MGffOptions` object.
;
; :Examples:
;   Try::
;
;     IDL> config = mgffoptions()
;     IDL> config->put, 'City', 'Boulder', section='Mike'
;     IDL> config->put, 'State', 'Colorado', section='Mike'
;     IDL> config->put, 'City', 'Madison', section='Mark'
;     IDL> config->put, 'State', 'Wisconsin', section='Mark'
;     IDL> foreach section, config, section_name do $
;     IDL>   print, section_name, section['City'], section['State'], $
;     IDL>          format='(%"%s lives in %s, %s.")'
;     Mark lives in Madison, Wisconsin.
;     Mike lives in Boulder, Colorado.
;
;
; :Returns:
;   1 if there is an element to return, 0 if there are no elements to retrieve
;
; :Params:
;   value : in, required, type=string
;     sections hash
;   key : in, required, type=string
;     section name
;-
function mgffoptions::_overloadForeach, value, key
  compile_opt strictarr

  if (n_elements(self.sections) eq 0L) then return, 0L

  keys = self.sections->keys()
  section_names = keys->toArray()
  obj_destroy, keys

  if (n_elements(key) eq 0L) then begin
    key = section_names[0]
    value = (self.sections)[key]
    return, 1L
  endif

  ind = where(section_names eq key, count)
  if (count eq 0L) then begin
    return, 0L
  endif else begin
    if (ind[0] eq n_elements(section_names) - 1L) then begin
      return, 0L
    endif else begin
      key = section_names[ind[0] + 1L]
      value = (self.sections)[key]
      return, 1L
    endelse
  endelse
end


;+
; Print help message about an `MGffOptions` object.
;
; :Examples:
;   For example::
;
;     IDL> help, config
;     CONFIG          MGFFOPTIONS  <NSECTIONS=2  NOPTIONS=4>
;
; :Returns:
;   string
;
; :Params:
;   varname : in, required, type=string
;     `MGffOptions` object variable name
;-
function mgffoptions::_overloadHelp, varname
  compile_opt strictarr

  nsections = n_elements(self.sections)
  noptions = 0L
  foreach sec, self.sections do noptions += n_elements(sec)

  return, string(varname, obj_class(self), nsections, noptions, $
                 format='(%"%-15s %s  <NSECTIONS=%d  NOPTIONS=%d>")')
end


;+
; Print `MGffOptions` object content in an INI format that can be read by
; `MG_READ_CONFIG`.
;
; :Examples:
;   For example::
;
;     IDL> print, config
;     [Mark]
;     City:   Madison
;     State:  Wisconsin
;
;     [Mike]
;     City:   Boulder
;     State:  Colorado
;
; :Returns:
;   string
;-
function mgffoptions::_overloadPrint
  compile_opt strictarr

  first_line = 1B
  output_list = list()

  max_width = 0L
  foreach sec, self.sections do begin
    foreach option, sec, o do begin
      max_width >= strlen(o)
    endforeach
  endforeach

  format = string(max_width + 2L, format='(%"(\%\"\%-%ds \%s\"\)")')

  if (self.sections->hasKey('')) then begin
    default_sec = (self.sections)['']
    foreach option, default_sec, o do begin
      first_line = 0B
      output_list->add, string(o + ':', option, format=format)
    endforeach
  endif

  foreach sec, self.sections, s do begin
    if (s eq '') then continue
    if (~first_line) then output_list->add, '' else first_line = 0B

    output_list->add, string(s, format='(%"[%s]")')
    foreach option, sec, o do begin
      output_list->add, string(o + ':', option, format=format)
    endforeach
  endforeach

  output = transpose(output_list->toArray())
  obj_destroy, output_list
  return, output
end


;= property access

;+
; Retrieve properties of the options object.
;-
pro mgffoptions::getProperty, sections=sections
  compile_opt strictarr

  if (arg_present(sections)) then begin
    _sections = self.sections->keys()
    sections = _sections->toArray()
    obj_destroy, _sections
  endif
end


;= get, put, and query


;+
; Put a new option into the `MGffOptions` object.
;
; :Params:
;   option : in, required, type=string
;     option name
;   value : in, required, type=string
;     option value
;
; :Keywords:
;   section : in, optional, type=string, default=''
;     section name to place option in
;-
pro mgffoptions::put, option, value, section=section
  compile_opt strictarr

  _section = n_elements(section) gt 0L ? section : ''

  case n_params() of
    0: message, 'option and value not specified'
    1: message, 'option or value not specified'
    2: _option = option
  endcase

  if (self.fold_case) then begin
    _section = strlowcase(_section)
    _option = strlowcase(_option)
  endif

  if (~self.sections->hasKey(_section)) then (self.sections)[_section] = hash()
  ((self.sections)[_section])[_option] = size(value, /n_dimensions) eq 0L $
                                         ? value $
                                         : ('[ ' + strjoin(value, ', ') + ' ]')
end


;+
; Determine if an options object has a given section.
;
; :Returns:
;   1B if section present, 0B if not
;
; :Params:
;   section : in, required, type=string
;     section to check
;-
function mgffoptions::has_section, section
  compile_opt strictarr

  return, self.sections->hasKey(self.fold_case ? strlowcase(section) : section)
end


;+
; Determine if a particular section has a given option.
;
; :Returns:
;   1B if option present, 0B if not
;
; :Params:
;   option : in, required, type=string
;     option to check
;
; :Keywords:
;   section : in, required, type=string
;     section to check
;-
function mgffoptions::has_option, option, section=section
  compile_opt strictarr

  _section = n_elements(section) gt 0L ? section : ''
  _option = option

  if (self.fold_case) then begin
    _section = strlowcase(_section)
    _option = strlowcase(_option)
  endif

  return, self.sections->hasKey(_section) && (self.sections)[_section]->hasKey(_option)
end


;+
; Return an array of the option names for a given section.
;
; :Returns:
;   `strarr`, or `!null` if no options present
;
; :Keywords:
;   section : in, required, type=string
;     section to list options for
;   count : out, optional, type=long
;     set to a named variable to retrieve the number of options returned
;-
function mgffoptions::options, section=section, count=count
  compile_opt strictarr

  count = 0L
  _section = n_elements(section) eq 0L ? '' : section

  if (self.fold_case) then begin
    _section = strlowcase(_section)
  endif

  if (~self->has_section(_section)) then return, []

  option_list = (self.sections)[_section]->keys()
  count = option_list->count()
  options = option_list->toArray()
  obj_destroy, option_list

  return, options
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
;   count : out, optional, type=long
;     set to a named variable to determine the number of elements returned (most
;     useful when using `EXTRACT`)
;   default : in, optional, type=string
;     default value to return if option is not found
;-
function mgffoptions::get, option, $
                           section=section, $
                           found=found, $
                           raw=raw, $
                           extract=extract, $
                           count=count, $
                           default=default
  compile_opt strictarr
  on_error, 2

  count = 0L
  _default = n_elements(default) eq 0L ? !null : default

  if (n_params() lt 1L) then message, 'option not specified'
  _option = option
  _section = n_elements(section) gt 0L ? section : ''

  if (self.fold_case) then begin
    _section = strlowcase(_section)
    _option = strlowcase(_option)
  endif

  found = 0B
  if (~self.sections->hasKey(_section)) then return, _default
  if (~(self.sections)[_section]->hasKey(_option)) then return, _default
  count = 1L

  found = 1B
  if (keyword_set(raw)) then begin
    value = ((self.sections)[_section])[_option]
  endif else begin
    value = mg_subs(((self.sections)[_section])[_option], $
                    (self.sections)[_section], $
                    unresolved_keys=unresolved_keys)
    if (_section ne '' && self.sections->hasKey('')) then begin
      value = mg_subs(value, (self.sections)[''], unresolved_keys=unresolved_keys)
    endif
  endelse

  if (keyword_set(extract)) then begin
    ;vars_re = '\[[[:space:]]*([-[:alnum:]._$]+[[:space:]]*,[[:space:]]*)*[-[:alnum:]._$]+[[:space:]]*\][[:space:]]*'
    vars_re = '\[.*\]'
    has_vars = stregex(value, vars_re, /boolean)
    if (has_vars) then begin
      vars_string = strmid(value, 1, strlen(value) - 2)
      value = strtrim(strsplit(vars_string, ',', /extract, count=count), 2)
    endif else begin
      value = [value]
    endelse
  endif

  return, value
end


;= lifecycle


;+
; Free resources of `mgffoptions` object.
;-
pro mgffoptions::cleanup
  compile_opt strictarr

  foreach s, self.sections do obj_destroy, s
  obj_destroy, self.sections
end


;+
; Initialize `mgffoptions` object.
;
; :Returns:
;   1 for success, 0 for failure
;-
function mgffoptions::init, fold_case=fold_case
  compile_opt strictarr


  self.fold_case = keyword_set(fold_case)
  self.sections = hash()

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;   fold_case
;     set to 1 for case-insensitive, 0 for case-sensitive
;   sections
;     hash of hashes
;-
pro mgffoptions__define
  compile_opt strictarr
  
  dummy = { MGffOptions, inherits IDL_Object, $
            fold_case: 0B, $
            sections: obj_new() $
          }
end


; main-level example

; example of putting all options in the default section
simple_config = mgffoptions(/fold_case)
simple_config->put, 'Name', 'Mike'
simple_config->put, 'City', 'Boulder'
simple_config->put, 'State', 'Colorado'
print, simple_config->get('name'), $
       simple_config->get('city'), $
       simple_config->get('state'), $
       format='(%"%s lives in %s, %s.")'

print

; example of using sections
config = mgffoptions()
config->put, 'City', 'Boulder', section='Mike'
config->put, 'State', 'Colorado', section='Mike'
config->put, 'City', 'Madison', section='Mark'
config->put, 'State', 'Wisconsin', section='Mark'
foreach section, config, section_name do $
  print, section_name, section['City'], section['State'], $
         format='(%"%s lives in %s, %s.")'

end

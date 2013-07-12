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
;-


;= overload methods


;+
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


function mgffoptions::_overloadForeach, value, key
  compile_opt strictarr

  if (self.sections->isEmpty()) then return, 0L

  keys = self.sections->keys()
  section_names = keys->toArray()
  obj_destroy, keys

  if (n_elements(key) eq 0L) then begin
    key = section_names[0]
    value = self.sections[key]
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
      value = self.sections[key]
      return, 1L
    endelse
  endelse
end


function mgffoptions::_overloadHelp, varname
  compile_opt strictarr

  nsections = n_elements(self.sections)
  noptions = 0L
  foreach sec, self.sections do noptions += n_elements(sec)

  return, string(varname, obj_class(self), nsections, noptions, $
                 format='(%"%-15s %s  <NSECTIONS=%d  NOPTIONS=%d>")')
end


function mgffoptions::_overloadPrint
  compile_opt strictarr

  first_line = 1B
  output_list = list()
  foreach sec, self.sections, s do begin
    if (~first_line) then output_list->add, '' else first_line = 0B

    output_list->add, string(s, format='(%"[ %s ]")')
    foreach option, sec, o do begin
      output_list->add, string(o, option, format='(%"  %s: %s")')
    endforeach
  endforeach

  output = transpose(output_list->toArray())
  obj_destroy, output_list
  return, output
end


;= get, set, and query


pro mgffoptions::put, option, value, section=section
  compile_opt strictarr

  _section = n_elements(section) gt 0L ? section : ''

  case n_params() of
    0: message, 'option and value specified'
    1: message, 'option or value not specified'
    2: _option = option
  endcase

  if (self.fold_case) then begin
    _section = strlowcase(_section)
    _option = strlowcase(_option)
  endif

  if (~self.sections->hasKey(_section)) then self.sections[_section] = hash()
  (self.sections[_section])[_option] = value
end


function mgffoptions::has_option, option, section=section
  compile_opt strictarr

  _section = n_elements(section) gt 0L ? section : ''

  if (~self.sections->hasKey(_section)) then return, 0B
  if (~self.sections[_section]->hasKey(option)) then return, 0B

  return, 1B
end


function mgffoptions::get, option, section=section, found=found, raw=raw
  compile_opt strictarr
  on_error, 2

  if (n_params() lt 1L) then message, 'option not specified'
  _option = option
  _section = n_elements(section) gt 0L ? section : ''

  if (self.fold_case) then begin
    _section = strlowcase(_section)
    _option = strlowcase(_option)
  endif

  found = 0B
  if (~self.sections->hasKey(_section)) then return, !null
  if (~self.sections[_section]->hasKey(_option)) then return, !null

  found = 1B
  if (keyword_set(raw)) then begin
    return, (self.sections[_section])[_option]
  endif else begin
    value = mg_subs((self.sections[_section])[_option], $
                    self.sections[_section], $
                    unresolved_keys=unresolved_keys)
    if (_section ne '' && self.sections->hasKey('')) then begin
      value = mg_subs(value, self.sections[''], unresolved_keys=unresolved_keys)
    endif
    return, value
  endelse
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
foreach section, config, section_name do begin
  print, section_name, section['City'], section['State'], $
         format='(%"%s lives in %s, %s.")'
endforeach

end

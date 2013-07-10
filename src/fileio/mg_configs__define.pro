; docformat = 'rst'

;= overload methods

function mg_configs::_overloadBracketsRightSide, isRange, ss1, ss2
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


pro mg_configs::_overloadBracketsLeftSide, obj, value, isRange, ss1, ss2
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


function mg_configs::_overloadForeach, value, key
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


;= get, set, and query


pro mg_configs::put, option, value, section=section
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


function mg_configs::has_option, option, section=section
  compile_opt strictarr

  _section = n_elements(section) gt 0L ? section : ''

  if (~self.sections->hasKey(_section)) then return, 0B
  if (~self.sections[_section]->hasKey(option)) then return, 0B

  return, 1B
end


function mg_configs::get, option, section=section, found=found
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
  return, (self.sections[_section])[_option]
end


;= lifecycle


pro mg_configs::cleanup
  compile_opt strictarr

  foreach s, self.sections do obj_destroy, s
  obj_destroy, self.sections
end


function mg_configs::init, fold_case=fold_case
  compile_opt strictarr

  self.fold_case = keyword_set(fold_case)
  self.sections = hash()

  return, 1
end


pro mg_configs__define
  compile_opt strictarr
  
  dummy = { mg_configs, inherits IDL_Object, $
            fold_case: 0B, $
            sections: obj_new() $
          }
end

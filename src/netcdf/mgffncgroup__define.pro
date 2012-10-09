; docformat = 'rst'

;+
; Class representing a netCDF group.
;
; :Categories:
;    file i/o, netcdf, sdf
;
; :Properties:
;    attributes
;       names of attributes of object
;    variables
;       names of child variables
;    groups
;       names of child groups
;    name
;       name of the group
;    fullname
;       full path to object inside the netCDF hierarchy
;-


;+
; Get an attribute value.
;
; :Private:
;
; :Returns:
;    attribute value or `!null` if not found
;
; :Params:
;    name : in, required, type=string
;       name of the attribute to retrieve
;
; :Keywords:
;    found : out, optional, type=boolean
;       set to a named variable to get whether the attribute was found
;-
function mgffncvariable::_getAttribute, name, found=found
  compile_opt strictarr

  found = 0B
  return, !null
end


;+
; Get properties.
;-
pro mgffncgroup::getProperty, attributes=attributes, $
                              groups=groups, $
                              variables=variables, $
                              name=name, $
                              fullname=fullname, $
                              _ref_extra=e
  compile_opt strictarr

  if (arg_present(attributes)) then attributes = !null

  if (arg_present(groups)) then begin
    group_ids = ncdf_groupsinq(self.id)

    if (group_ids[0] eq -1L) then begin
      groups = !null
    endif else begin
      groups = strarr(n_elements(group_ids))

      for g = 0L, n_elements(group_ids) - 1L do begin
        groups[g] = ncdf_groupname(group_ids[g])
      endfor
    endelse
  endif

  if (arg_present(variables)) then begin
    var_ids = ncdf_varidsinq(self.id)

    if (var_ids[0] eq -1L) then begin
      variables = !null
    endif else begin
      variables = strarr(n_elements(var_ids))
      for v = 0L, n_elements(var_ids) - 1L do begin
        var_info = ncdf_varinq(self.id, var_ids[v])
        variables[v] = var_info.name
      endfor
    endelse
  endif

  if (arg_present(name)) then name = ncdf_groupname(self.id)
  if (arg_present(fullname)) then fullname = ncdf_fullgroupname(self.id)

  if (n_elements(e) gt 0L) then self->MGffNCBase::getProperty, _extra=e
end


;+
; Returns the output display by HELP on an object of the class.
;
; :Returns:
;    string
;
; :Params:
;    varname : in, required, type=string
;       name of the variable to get help about, passed in to display in HELP
;       output
;-
function mgffncgroup::_overloadHelp, varname
  compile_opt strictarr

  type = 'NCGroup'
  specs = string(ncdf_fullgroupname(self.id), format='(%"%s")')
  return, self->MGffNCBase::_overloadHelp(varname, type=type, specs=specs)
end


;+
; Get output for use with PRINT
;
; :Returns:
;    string
;
; :Keywords:
;    indent : in, optional, type=string
;       indent to use when printing message
;-
function mgffncgroup::dump, indent=indent
  compile_opt strictarr

  result = ''
  _indent = n_elements(indent) eq 0L ? '' : indent

  result += string(_indent eq '' ? '' : mg_newline(), _indent, $
                   ncdf_groupname(self.id), $
                   format='(%"%s%s+ GROUP %s")')

  self->getProperty, attributes=attributes
  foreach att_name, attributes do begin
    result += string(mg_newline(), _indent, att_name, format='(%"%s%s  = ATTRIBUTE %s")')
  endforeach

  self->getProperty, groups=groups
  foreach group_name, groups do begin
    result += self[group_name]->dump(indent=_indent + '  ')
  endforeach

  self->getProperty, variables=variables
  foreach var_name, variables do begin
    result += self[var_name]->dump(indent=_indent + '  ')
  endforeach

  return, result
end


;+
; Get output for use with PRINT
;
; :Returns:
;    string
;-
function mgffncgroup::_overloadPrint
  compile_opt strictarr

  return, self->dump()
end


;+
; Get attributes, groups, or variables from a file.
;
; :Returns:
;    attribute value, group object, or variable object
;
; :Params:
;    isRange : in, required, type=lonarr(ndims)
;       array indicating whether each dimensions present is a range or a list
;       of indices
;    ss1 : in, required, type=string
;       name of subgroup or variable
;    ss2 : in, optional, type=any
;       unused
;    ss3 : in, optional, type=any
;       unused
;    ss4 : in, optional, type=any
;       unused
;    ss5 : in, optional, type=any
;       unused
;    ss6 : in, optional, type=any
;       unused
;    ss7 : in, optional, type=any
;       unused
;    ss8 : in, optional, type=any
;       unused
;-
function mgffncgroup::_overloadBracketsRightSide, isRange, $
                                                  ss1, ss2, ss3, ss4, $
                                                  ss5, ss6, ss7, ss8
  compile_opt strictarr
  on_error, 2

  ; check the variables for one with the given name
  vars = ncdf_varidsinq(self.id)
  for v = 0L, n_elements(vars) - 1 do begin
    if (vars[v] eq -1L) then break
    name = (ncdf_varinq(self.id, vars[v])).name
    if (name eq ss1) then begin
      new_var = obj_new('MGffNCVariable', identifier=vars[v], parent=self)
      self.children->add, new_var
      return, new_var
    endif
  endfor

  ; check the groups for one with the given name
  groups = ncdf_groupsinq(self.id)
  for g = 0L, n_elements(groups) - 1L do begin
    if (groups[g] eq -1L) then break
    name = ncdf_groupname(groups[g])
    if (name eq ss1) then begin
      new_group = obj_new('MGffNCGroup', identifier=groups[g], parent=self)
      self.children->add, new_group
      return, new_group
    endif
  endfor

  message, string(ss1, format='(%"%s not found")')
end


;+
; Free resources.
;-
pro mgffncgroup::cleanup
  compile_opt strictarr

  obj_destroy, self.children
end


;+
; Create a netCDF group object.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mgffncgroup::init, _extra=e
  compile_opt strictarr

  if (~self->MGffNCBase::init(_extra=e)) then return, 0

  self.children = obj_new('IDL_Container')

  return, 1
end


;+
; Define instance variables and class inheritance.
;
; :Fields:
;    children
;       `IDL_Container` containing child groups/variables
;-
pro mgffncgroup__define
  compile_opt strictarr

  define = { MGffNCGroup, inherits MGffNCBase, $
             children: obj_new() $
           }
end

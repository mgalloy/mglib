; docformat = 'rst'

;+
; Class of functionality common to files, groups, and variables.
;
; :Categories:
;    file i/o, netcdf, sdf
;
; :Properties:
;    identifier
;       netCDF object identifier
;    parent
;       parent object in netCDF hierarchy
;-


;+
; Returns a string printing the value of an attribute.
;
; :Private:
;
; :Returns:
;    string
;
; :Params:
;    parent_id : in, required, type=long
;       identifier of the file, not used if `GLOBAL` is set
;    id : in, required, type=long
;       attribute identifier, set to file identifier if `GLOBAL` is set
;    attnum : in, required, type=long
;       attribute index
;-
function mgffncbase::_printAttribute, parent_id, id, attnum, global=global, $
                                      indent=indent
  compile_opt strictarr

  if (keyword_set(global)) then begin
    attname = ncdf_attname(id, attnum, /global)
    attinfo = ncdf_attinq(id, attname, /global)
    if (attinfo.dataType eq 'CHAR') then begin
      ncdf_attget, id, attname, attvalue, /global
    endif
  endif else begin
    attname = ncdf_attname(parent_id, id, attnum)
    attinfo = ncdf_attinq(parent_id, id, attname)
    if (attinfo.dataType eq 'CHAR') then begin
      ncdf_attget, parent_id, id, attname, attvalue
    endif
  endelse

  result = ''
  _indent = n_elements(indent) eq 0L ? '' : indent

  length = attinfo.dataType eq 'CHAR' ? (attinfo.length - 1L) : attinfo.length

  if (attinfo.dataType eq 'CHAR') then begin
    ; print only first line or first 60 characters
    ind = where(attvalue eq 10B or attvalue eq 13B, count)
    if (count gt 0L) then begin
      attValue = ind[0] eq 0L ? '' : string(attvalue[0:ind[0] - 1])
      truncated = 1B
    endif else begin
      attValue = string(attvalue)
      truncated = 0B
    endelse

    if (strlen(attvalue) gt 60) then begin
      attValue = strmid(attvalue, 0, 60)
      truncated = 1B
    endif

    result += string(mg_newline(), $
                     _indent, $
                     attname, $
                     attvalue, $
                     truncated ? '...' : '', $
                     format='(%"%s%s  . ATTRIBUTE %s = ''%s''%s")')
  endif else begin
    result += string(mg_newline(), $
                     _indent, $
                     mg_nc_typedecl(attinfo.dataType), $
                     length, $
                     attname, $
                     format='(%"%s%s  . ATTRIBUTE %s(%d) %s")')
  endelse

  return, result
end


;+
; Get properties.
;-
pro mgffncbase::getProperty, identifier=identifier, $
                             parent=parent

  compile_opt strictarr

  if (arg_present(identifier)) then identifier = self.id
  if (arg_present(parent)) then parent = self.parent
end


;+
; Get properties.
;-
pro mgffncbase::setProperty
  compile_opt strictarr

end


;+
; HELP overload common routine.
;
; :Params:
;    varname : in, required, type=string
;       name of variable to provide HELP for
;
; :Keywords:
;    type : in, optional, type=string, default='NC_BASE'
;       type for object
;    specs : in, optional, type=string, default='<undefined>'
;       specs for object, depending on object type
;-
function mgffncbase::_overloadHelp, varname, type=type, specs=specs
  compile_opt strictarr

  _type = n_elements(type) eq 0L ? 'NC_BASE' : type
  _specs = n_elements(specs) eq 0L ? '<undefined>' : specs

  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;+
; Free resources.
;-
pro mgffncbase::cleanup
  compile_opt strictarr

end


;+
; Do base instantiation.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mgffncbase::init, identifier=identifier, parent=parent
  compile_opt strictarr

  self.id = identifier
  self.parent = n_elements(parent) eq 0L ? obj_new()  : parent

  return, 1
end


;+
; Define instance variables and class inheritance.
;
; :Fields:
;    id
;       netCDF identifier for object
;-
pro mgffncbase__define
  compile_opt strictarr

  define = { MGffNCBase, inherits IDL_Object, $
             parent: obj_new(), $
             id: 0L $
           }
end

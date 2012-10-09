; docformat = 'rst'

;+
; Class representing netCDF variable.
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
;-

;+
; Compute the hyperslab arguments from the bounds.
;
; :Private:
;
; :Params:
;    bounds : in, required, type="lonarr(ndims, 3)"
;       bounds
;
; :Keywords:
;    offset : out, optional, type=lonarr(ndims)
;       input for offset argument to NCDF_VARGET
;    count : out, optional, type=lonarr(ndims)
;       input for count argument to NCDF_VARGET
;    stride : out, optional, type=lonarr(ndims)
;       input for stride keyword to NCDF_VARGET
;-
pro mgffncvariable::_computeslab, bounds, $
                                  offset=offset, $
                                  count=count, $
                                  stride=stride
  compile_opt strictarr

  ndims = (size(bounds, /dimensions))[0]

  offset = reform(bounds[*, 0])
  stride = reform(bounds[*, 2])

  count = ceil((bounds[*, 1] - bounds[*, 0] + 1L) / float(bounds[*, 2])) > 1
end


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
  self.parent->getProperty, identifier=parent_id

  varinfo = ncdf_varinq(parent_id, self.id)
  for a = 0L, varinfo.natts - 1L do begin
    attname = ncdf_attname(parent_id, self.id, a)
    if (name eq attname) then begin
      ncdf_attget, parent_id, self.id, name, attvalue
      attinfo = ncdf_attinq(parent_id, self.id, name)
      found = 1B
      return, attinfo.dataType eq 'CHAR' ? string(attvalue) : attvalue
    endif
  endfor

  return, !null
end


;+
; Get properties.
;-
pro mgffncvariable::getProperty, attributes=attributes, $
                                 groups=groups, $
                                 variables=variables, $
                                 name=name, $
                                 data_type=dataType, $
                                 n_dimensions=ndims, $
                                 n_attributes=natts, $
                                 dimensions=dims, $
                                 _ref_extra=e
  compile_opt strictarr

  if (arg_present(attributes)) then begin
    self.parent->getProperty, identifier=parent_id

    info = ncdf_varinq(parent_id, self.id)

    if (info.natts eq 0L) then begin
      attributes = !null
    endif else begin
      attributes = strarr(info.natts)
      for a = 0L, info.natts - 1L do begin
        attributes[a] = ncdf_attname(parent_id, self.id, a)
      endfor
    endelse
  endif

  if (arg_present(groups)) then groups = !null
  if (arg_present(variables)) then variables = !null

  if (arg_present(name) || arg_present(dataType) || arg_present(ndims) $
        || arg_present(natts) || arg_present(dims)) then begin
    self.parent->getProperty, identifier=parentId
    varInfo = ncdf_varinq(parentId, self.id)
    name = varInfo.name
    dataType = varInfo.dataType
    ndims = varInfo.ndims
    natts = varInfo.natts
    if (arg_present(dims)) then begin
      dims = lonarr(ndims)
      for d = 0L, n_elements(dims) - 1L do begin
        ncdf_diminq, parentId, varInfo.dim[d], dimName, dimSize
        dims[d] = dimSize
      endfor
    endif
  endif

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
function mgffncvariable::_overloadHelp, varname
  compile_opt strictarr

  self->getProperty, name=name, data_type=datatype, dimensions=dims
  sdims = strtrim(dims, 2)
  specs = string(name, strjoin(sdims, ', '), format='(%"NCVariable:%s[%s]")')

  return, self->MGffNCBase::_overloadHelp(varname, type=datatype, specs=specs)
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
function mgffncvariable::dump, indent=indent
  compile_opt strictarr

  _indent = n_elements(indent) eq 0L ? '' : indent

  self.parent->getProperty, identifier=parent_id

  varInfo = ncdf_varinq(parent_id, self.id)
  dims = varInfo.dim * 0L
  for d = 0L, n_elements(dims) - 1L do begin
    ncdf_diminq, parent_id, varInfo.dim[d], dimName, dimSize
    dims[d] = dimSize
  endfor

  result = ''

  dimDecl = varinfo.dataType eq 'CHAR' ? (dims - 1L) : dims
  result = string(_indent eq '' ? '' : mg_newline(), $
                  _indent, $
                  mg_nc_typedecl(varinfo.dataType), $
                  strjoin(strtrim(dimDecl, 2), ', '), $
                  varinfo.name, $
                  format='(%"%s%s- VARIABLE %s(%s) %s")')

  for a = 0L, varInfo.natts - 1L do begin
    result += self->_printAttribute(parent_id, self.id, a, indent=indent)
  endfor

  return, result
end


;+
; Get output for use with PRINT
;
; :Returns:
;    string
;-
function mgffncvariable::_overloadPrint
  compile_opt strictarr

  self.parent->getProperty, identifier=parent_id
  ncdf_varget, parent_id, self.id, value

  return, value
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
;    ss1 : in, required, type=lonarr
;       if corresponding element of `isRange` is 1B, then `ss1` is a
;       3-element array specifying start index, end index, and stride,
;       otherwise an `n` element list of indices
;    ss2 : in, required, type=lonarr
;       if corresponding element of `isRange` is 1B, then `ss2` is a
;       3-element array specifying start index, end index, and stride,
;       otherwise an `n` element list of indices
;    ss3 : in, required, type=lonarr
;       if corresponding element of `isRange` is 1B, then `ss3` is a
;       3-element array specifying start index, end index, and stride,
;       otherwise an `n` element list of indices
;    ss4 : in, required, type=lonarr
;       if corresponding element of `isRange` is 1B, then `ss4` is a
;       3-element array specifying start index, end index, and stride,
;       otherwise an `n` element list of indices
;    ss5 : in, required, type=lonarr
;       if corresponding element of `isRange` is 1B, then `ss5` is a
;       3-element array specifying start index, end index, and stride,
;       otherwise an `n` element list of indices
;    ss6 : in, required, type=lonarr
;       if corresponding element of `isRange` is 1B, then `ss6` is a
;       3-element array specifying start index, end index, and stride,
;       otherwise an `n` element list of indices
;    ss7 : in, required, type=lonarr
;       if corresponding element of `isRange` is 1B, then `ss7` is a
;       3-element array specifying start index, end index, and stride,
;       otherwise an `n` element list of indices
;    ss8 : in, required, type=lonarr
;       if corresponding element of `isRange` is 1B, then `ss8` is a
;       3-element array specifying start index, end index, and stride,
;       otherwise an `n` element list of indices
;-
function mgffncvariable::_overloadBracketsRightSide, isRange, $
                                                     ss1, ss2, ss3, ss4, $
                                                     ss5, ss6, ss7, ss8
  compile_opt strictarr
  on_error, 2

  if (size(ss1, /type) eq 7) then begin
    attvalue = self->_getAttribute(ss1, found=found)
    if (found) then return, attvalue
    message, string(ss1, format='(%"attribute %s not found")'), /informational
    return, !null
  endif

  self.parent->getProperty, identifier=parent_id

  info = ncdf_varinq(parent_id, self.id)

  dim_sizes = lonarr(info.ndims)
  for d = 0L, info.ndims - 1L do begin
    ncdf_diminq, parent_id, info.dim[d], name, dsize
    dim_sizes[d] = dsize
  endfor

  bounds = lonarr(info.ndims, 3)

  if (n_elements(ss1) gt 0L) then bounds[0, 0:2] = ss1
  if (n_elements(ss2) gt 0L) then bounds[1, 0:2] = ss2
  if (n_elements(ss3) gt 0L) then bounds[2, 0:2] = ss3
  if (n_elements(ss4) gt 0L) then bounds[3, 0:2] = ss4
  if (n_elements(ss5) gt 0L) then bounds[4, 0:2] = ss5
  if (n_elements(ss6) gt 0L) then bounds[5, 0:2] = ss6
  if (n_elements(ss7) gt 0L) then bounds[6, 0:2] = ss7
  if (n_elements(ss8) gt 0L) then bounds[7, 0:2] = ss8

  for d = 0L, info.ndims - 1L do begin
    if (bounds[d, 1] eq -1L) then bounds[d, 1] = dim_sizes[d] - 1L
  endfor

  self->_computeslab, bounds, count=count, offset=offset, stride=stride

  ncdf_varget, parent_id, self.id, value, $
               count=count, offset=offset, stride=stride

  return, value
end


;+
; Free resources.
;-
pro mgffncvariable::cleanup
  compile_opt strictarr

  self->MGffNCBase::cleanup
end


;+
; Create a netCDF variable object.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mgffncvariable::init, _extra=e
  compile_opt strictarr

  if (~self->MGffNCBase::init(_extra=e)) then return, 0

  return, 1
end


;+
; Define instance variables.
;-
pro mgffncvariable__define
  compile_opt strictarr

  define = { MGffNCVariable, inherits MGffNCBase }
end

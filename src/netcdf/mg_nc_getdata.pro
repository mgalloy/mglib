; docformat = 'rst'

;+
; Routine for extracting datasets, slices of datasets, or attributes from
; an netCDF file with simple notation.
;
; :Categories:
;   file i/o, netcdf, sdf
;
; :Examples:
;   An example file is provided with the IDL distribution::
;
;     IDL> sample_filename = file_which('sample.nc')
;
;   A full variable can be pulled out of the file easily::
;
;     IDL> im = mg_nc_getdata(sample_filename, '/image')
;
;   Or an attribute::
;
;     IDL> title = mg_nc_getdata(sample_filename, '/image.TITLE')
;
;   You can use basic IDL array notations to retrieve a portion of an array::
;
;     IDL> line = mg_nc_getdata(sample_filename, '/image[*, 256]')
;
;   And then display::
;
;     IDL> dims = size(im, /dimensions)
;     IDL> window, /free, title=title, xsize=dims[0], ysize=dims[1]
;     IDL> tvscl, im
;
;     IDL> window, /free, title='Profile at row = 256', xsize=600, ysize=200
;     IDL> plot, line, yrange=[0, 255], xstyle=9, ystyle=9
;
;    This example is available as a main-level program included in this file::
;
;       IDL> .run mg_nc_getdata
;
; :Author:
;   Michael Galloy
;-


;+
; Converts 1 dimension of a possibly multi-dimensional set of indices
; to `[start_index, stop_index, stride]` form.
;
; :Private:
;
; :Returns:
;   `lonarr(3)`
;
; :Params:
;   sbounds : in, required, type=string
;     notation for 1 dimension, e.g., '0', '3:9', '3:*:2'
;   dim_size : in, required, type=lonarr
;     size of the dimension being converted
;-
function mg_nc_getdata_convertbounds_1d, sbounds, dim_size
  compile_opt strictarr

  args = strsplit(sbounds, ':', /extract, count=nargs)
  result = [0L, dim_size - 1L, 1L]

  case nargs of
    1: begin
        if (args[0] ne '*') then begin
          index = long(args)
          if (index lt 0L) then index += dim_size
          result[0:1] = index
        endif
      end
    2: begin
        if (args[1] eq '*') then begin
          result[0] = long(args[0])
          result[0]  = result[0] lt 0L ? (dim_size + result[0]) : result[0]
        endif else begin
          result[0:1] = long(args)
          if (result[0] lt 0L) then result[0] = dim_size + result[0]
          if (result[1] lt 0L) then result[1] = dim_size + result[1]
        endelse
      end
    3: begin
        if (args[1] eq '*') then begin
          result[0] = long(args[0])
          result[0]  = result[0] lt 0L ? (dim_size + result[0]) : result[0]
          result[2] = long(args[2])
        endif else begin
          result[0:2] = long(args)
          if (result[0] lt 0L) then result[0] = dim_size + result[0]
          if (result[1] lt 0L) then result[1] = dim_size + result[1]
        endelse
      end
    else: message, 'invalid indexing notation: ' + sbounds
  endcase

  return, result
end


;+
; Converts normal IDL indexing notation (represented as a string) into a
; `lonarr(ndims, 3)` where the first row is start values, the second row is
; the end values, and the last row is the stride value.
;
; :Private:
;
; :Returns:
;   `lonarr(ndims, 3)`
;
; :Params:
;   sbounds : in, required, type=string
;     bounds specified as a string using IDL's normal indexing notation
;
; :Keywords:
;   dimensions : in, optional, type=lonarr(ndims)
;     dimensions of the full array; required if a '*' is used in sbounds
;   single : out, optional, type=boolean
;     set to a named variable to determine if the bounds expression was
;     specified in single-index dimensioning
;-
function mg_nc_getdata_convertbounds, sbounds, dimensions=dimensions, $
                                      single=single
  compile_opt strictarr
  on_error, 2

  dimIndices = strtrim(strsplit(sbounds, ',', /extract, count=ndims), 2)
  result = lonarr(ndims, 3)

  case ndims of
    1: begin
        single = 1B
        result[0, *] = mg_nc_getdata_convertbounds_1d(dimIndices[0],$
                                                      product(dimensions))
      end
    n_elements(dimensions): begin
        single = 0B
        for d = 0L, ndims - 1L do begin
          result[d, *] = mg_nc_getdata_convertbounds_1d(dimIndices[d], dimensions[d])
        endfor
      end
    else: message, 'invalid number of dimensions in array indexing notation'
  endcase

  return, result
end


;+
; Compute the hyperslab arguments from the bounds.
;
; :Private:
;
; :Params:
;   bounds : in, required, type="lonarr(ndims, 3)"
;     bounds
;
; :Keywords:
;   offset : out, optional, type=lonarr(ndims)
;     input for offset argument to NCDF_VARGET
;   count : out, optional, type=lonarr(ndims)
;     input for count argument to NCDF_VARGET
;   stride : out, optional, type=lonarr(ndims)
;     input for stride keyword to NCDF_VARGET
;-
pro mg_nc_getdata_computeslab, bounds, $
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
; Reads data in a dataset.
;
; :Private:
;
; :Returns:
;   value of data read from dataset
;
; :Params:
;   file_id : in, required, type=long
;     netCDF indentifier of the file
;   variable : in, required, type=string
;     string navigating the path to the dataset
;
; :Keywords:
;   bounds : in, optional, type="lonarr(3, ndims) or string"
;     gives start value, end value, and stride for each dimension of the
;     variable
;   error : out, optional, type=long
;     error value
;-
function mg_nc_getdata_getvariable, file_id, variable, bounds=bounds, $
                                    error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, !null
  endif

  ; get variable ID
  tokens = strsplit(variable, '/', /extract, count=n_tokens)
  group_id = file_id
  for i = 0L, n_tokens - 2L do begin
    group_id = ncdf_ncidinq(group_id, tokens[i])
  endfor
  varname = tokens[-1]

  var_id = mg_nc_varid(group_id, varname)

  ; get full dimensions of variable
  varInfo = ncdf_varinq(group_id, var_id)
  dimensions = lonarr(varInfo.ndims)
  for d = 0L, varInfo.ndims - 1L do begin
    ncdf_diminq, group_id, varInfo.dim[d], dimName, dimSize
    dimensions[d] = dimSize
  endfor

  fullBounds = [[lonarr(varInfo.ndims)], $
                [dimensions - 1L], $
                [lonarr(varInfo.ndims) + 1L]]

  ; convert input bounds to a lonarr(ndims, 3) bounds specification
  case size(bounds, /type) of
    0: _bounds = fullBounds
    7: _bounds = mg_nc_getdata_convertbounds(bounds, dimensions=dimensions)
    else: _bounds = transpose(bounds)
  endcase

  mg_nc_getdata_computeslab, _bounds, $
                             offset=offset, $
                             count=count, $
                             stride=stride

  ncdf_varget, group_id, var_id, value, count=count, offset=offset, stride=stride

  return, value
end


;+
; Get the value of the attribute from its group, dataset, or type.
;
; :Private:
;
; :Returns:
;   attribute data
;
; :Params:
;   group_id : in, required, type=long
;     identifier of netCDF file
;   parent_id : in, required, type=long
;     identifier of parent variable/group
;   attname : in, required, type=string
;     attribute name
;
; :Keywords:
;   global : in, optional, type=boolean
;     set to indicate that the attribute is a global attribute
;   error : out, optional, type=long
;     error value, 0 indicates success
;-
function mg_nc_getdata_getattributedata, group_id, parent_id, attname, $
                                         global=global, error=error
  compile_opt strictarr
  on_error, 2

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    !quiet = old_quiet
    return, !null
  endif

  old_quiet = !quiet
  ;!quiet = 1

  if (keyword_set(global)) then begin
    ncdf_attget, group_id, attname, attr_value, /global
    attr_info = ncdf_attinq(group_id, attname, /global)
  endif else begin
    ncdf_attget, group_id, parent_id, attname, attr_value
    attr_info = ncdf_attinq(group_id, parent_id, attname)
  endelse

  !quiet = old_quiet

  case attr_info.datatype of
    'CHAR': attr_value = string(attr_value)
    else:
  endcase

  return, attr_value
end


;+
; Get the value of an attribute in a file.
;
; :Private:
;
; :Returns:
;   attribute value
;
; :Params:
;   file_id : in, required, type=long
;     netCDF file identifier of the file to read
;   group_id : in, required, type=long
;     netCDF group identifier
;   parent_id : in, required, type=long
;     parent group/variable identifier
;   attname : in, required, type=string
;     name of attribute
;
; :Keywords:
;   error : out, optional, type=long
;     error value, 0 indicates success
;-
function mg_nc_getdata_getattribute, file_id, group_id, parent_id, attname, $
                                     error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, !null
  endif

  data = mg_nc_getdata_getattributedata(group_id, parent_id, attname, $
                                        global=group_id eq parent_id, $
                                        error=error)

  return, data
end


;+
; Pulls out a section of a netCDF variable.
;
; :Returns:
;   data array
;
; :Params:
;   filename : in, required, type=string
;     filename of the netCDF file
;   descriptor : in, required, type=string
;     descriptor for variable/attribute name (with path if inside a group)
;
; :Keywords:
;   bounds : in, optional, type="lonarr(3, ndims) or string"
;     gives start value, end value, and stride for each dimension of the
;     variable
;   error : out, optional, type=long
;     error value, 0 indicates success
;-
function mg_nc_getdata, filename, descriptor, bounds=bounds, error=error
  compile_opt strictarr
  on_error, 2

  error = 0L
  file_id = ncdf_open(filename, /nowrite)

  type = mg_nc_decompose(file_id, descriptor, $
                         parent_type=parent_type, $
                         parent_id=parent_id, $
                         group_id=group_id, $
                         element_name=element_name, $
                         error=error)
  if (error ne 0L) then return, !null

  case type of
    0: begin
        error = -1L
        result = !null
        if (~arg_present(error)) then message, 'unknown descriptor type', /informational
      end
    1: begin
         ; attribute
         result = mg_nc_getdata_getattribute(file_id, group_id, parent_id, $
                                             element_name, $
                                             error=error)
         if (error) then begin
           if (~arg_present(error)) then message, 'attribute not found', /informational
         endif
      end
    2: begin
         ; variable
         _variable = element_name

         bracketPos = strpos(element_name, '[')
         if (bracketPos eq -1L) then begin
           if (n_elements(bounds) gt 0L) then _bounds = bounds
         endif else begin
           closeBracketPos = strpos(element_name, ']', /reverse_search)
           _bounds = strmid(element_name, bracketPos + 1L, closeBracketPos - bracketPos - 1L)
           _variable = strmid(element_name, 0L, bracketPos)
         endelse

         result = mg_nc_getdata_getvariable(parent_id, _variable, $
                                            bounds=_bounds, $
                                            error=error)
         if (error) then begin
           if (~arg_present(error)) then message, 'variable not found', /informational
         endif
      end
    3: begin
        error = -1L
        result = !null
        if (~arg_present(error)) then message, 'unable to return group', /informational
      end
    else: begin
        error = -1L
        result = !null
        if (~arg_present(error)) then message, 'unknown descriptor type', /informational
      end
  endcase

  ncdf_close, file_id

  return, result
end


; main-level example program

sample_filename = file_which('sample.nc')
im = mg_nc_getdata(sample_filename, '/image')
title = mg_nc_getdata(sample_filename, '/image.TITLE')

line = mg_nc_getdata(sample_filename, '/image[*, 256]')

dims = size(im, /dimensions)
window, /free, title=title, xsize=dims[0], ysize=dims[1]
tvscl, im

window, /free, title='Profile at row = 256', xsize=600, ysize=200
plot, line, yrange=[0, 255], xstyle=9, ystyle=9

end

; docformat = 'rst'

;+
; Routine for extracting datasets, slices of datasets, or attributes from
; an netCDF file with simple notation.
;
; :Todo:
;   better error messages when items not found
;   access for global attributes
;
; :Categories:
;    file i/o, netcdf, sdf
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
;    Michael Galloy
;-


;+
; Converts 1 dimension of a possibly multi-dimensional set of indices
; to `[start_index, stop_index, stride]` form.
;
; :Private:
;
; :Returns:
;    `lonarr(3)`
;
; :Params:
;   sbounds : in, required, type=string
;      notation for 1 dimension, e.g., '0', '3:9', '3:*:2'
;   dim_size : in, required, type=lonarr
;      size of the dimension being converted
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
;    lonarr(ndims, 3)
;
; :Params:
;    sbounds : in, required, type=string
;       bounds specified as a string using IDL's normal indexing notation
;
; :Keywords:
;    dimensions : in, optional, type=lonarr(ndims)
;       dimensions of the full array; required if a '*' is used in sbounds
;    single : out, optional, type=boolean
;       set to a named variable to determine if the bounds expression was
;       specified in single-index dimensioning
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
    else:  message, 'invalid number of dimensions in array indexing notation'
  endcase

  return, result
end


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
;    value of data read from dataset
;
; :Params:
;    fileId : in, required, type=long
;       netCDF indentifier of the file
;    variable : in, required, type=string
;       string navigating the path to the dataset
;
; :Keywords:
;    bounds : in, optional, type="lonarr(3, ndims) or string"
;       gives start value, end value, and stride for each dimension of the
;       variable
;    error : out, optional, type=long
;       error value
;-
function mg_nc_getdata_getvariable, fileId, variable, bounds=bounds, $
                                    error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    error = 1L
    return, -1L
  endif

  ; get full dimensions of variable
  varId = ncdf_varid(fileId, variable)
  varInfo = ncdf_varinq(fileId, varId)
  dimensions = lonarr(varInfo.ndims)
  for d = 0L, varInfo.ndims - 1L do begin
    ncdf_diminq, fileId, varInfo.dim[d], dimName, dimSize
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

  ncdf_varget, fileId, varId, value, count=count, offset=offset, stride=stride

  return, value
end


;+
; Get the value of the attribute from its group, dataset, or type.
;
; :Private:
;
; :Returns:
;    attribute data
;
; :Params:
;    fileId : in, required, type=long
;       identifier of netCDF file
;    varId : in, required, type=long
;       identifier of variable
;    attname : in, required, type=string
;       attribute name
;-
function mg_h5_getdata_getattributedata, fileId, varId, attname, global=global
  compile_opt strictarr
  on_error, 2

  if (keyword_set(global)) then begin
    ncdf_attget, fileId, attname, attvalue, /global
    attInfo = ncdf_attinq(fileId, attname, /global)
  endif else begin
    ncdf_attget, fileId, varId, attname, attvalue
    attInfo = ncdf_attinq(fileId, varId, attname)
  endelse

  if (attInfo.dataType eq 'CHAR') then attvalue = string(attvalue)

  return, attvalue
end


;+
; Get the value of an attribute in a file.
;
; :Private:
;
; :Returns:
;    attribute value
;
; :Params:
;    fileId : in, required, type=long
;       netCDF file identifier of the file to read
;    variable : in, required, type=string
;       path to attribute using "/" to navigate groups/datasets and "." to
;       indicate the attribute name
;
; :Keywords:
;    error : out, optional, type=long
;       error value
;-
function mg_nc_getdata_getattribute, fileId, variable, error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    error = 1L
    return, -1L
  endif

  tokens = strsplit(variable, '.', escape='\', count=ndots)
  dotpos = tokens[ndots - 1L] - 1L
  loc = strmid(variable, 0, dotpos)
  attname = strmid(variable, dotpos + 1L)

  if (loc eq '') then begin
    data = mg_h5_getdata_getattributedata(fileId, -1L, attname, /global)
  endif else begin
    varId = ncdf_varid(fileId, loc)
    data = mg_h5_getdata_getattributedata(fileId, varId, attname)
  endelse

  return, data
end


;+
; Pulls out a section of a netCDF variable.
;
; :Returns:
;    data array
;
; :Params:
;    filename : in, required, type=string
;       filename of the netCDF file
;    variable : in, required, type=string
;       variable name (with path if inside a group)
;
; :Keywords:
;    bounds : in, optional, type="lonarr(3, ndims) or string"
;       gives start value, end value, and stride for each dimension of the
;       variable
;    error : out, optional, type=long
;       error value
;-
function mg_nc_getdata, filename, variable, bounds=bounds, error=error
  compile_opt strictarr
  on_error, 2

  fileId = ncdf_open(filename, /nowrite)
  tokens = strsplit(variable, '.', escape='\', count=ntokens, /preserve_null, /extract)
  ndots = ntokens - 1L

  _variable = ndots eq 0L ? tokens[0] : strjoin(tokens, '.')
  _variable = strpos(_variable, '/') eq 0L ? strmid(_variable, 1) : _variable

  if (ndots eq 0L) then begin
    ; variable
    bracketPos = strpos(_variable, '[')
    if (bracketPos eq -1L) then begin
      if (n_elements(bounds) gt 0L) then _bounds = bounds
    endif else begin
      closeBracketPos = strpos(_variable, ']', /reverse_search)
      _bounds = strmid(_variable, bracketPos + 1L, closeBracketPos - bracketPos - 1L)
      _variable = strmid(_variable, 0L, bracketPos)
    endelse

    result = mg_nc_getdata_getvariable(fileId, _variable, bounds=_bounds, $
                                       error=error)
    if (error) then message, 'variable not found', /informational
  endif else begin
    ; attribute
    result = mg_nc_getdata_getattribute(fileId, _variable, error=error)
    if (error) then message, 'attribute not found', /informational
  endelse

  ncdf_close, fileId

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

;ncgroup_filename = file_which('ncgroup.nc')

end

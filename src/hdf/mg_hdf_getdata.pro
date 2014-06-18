; docformat = 'rst'


;+
; Convert string bounds like `0:*` to a 3-element bounds specification::
;
;   [start_index, stop_index, string]
;
; :Private:
;
; :Returns:
;    `lonarr(3)`
;
; :Params:
;   sbounds : in, required, type=string
;     notation for 1 dimension, e.g., `0`, `3:9`, `3:*:2`
;   dim_size : in, required, type=lonarr
;     size of the dimension being converted
;-
function mg_hdf_getdata_convertbounds_1d, sbounds, dim_size
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
function mg_hdf_getdata_convertbounds, sbounds, dimensions=dimensions, $
                                       single=single
  compile_opt strictarr
  on_error, 2

  dimIndices = strtrim(strsplit(sbounds, ',', /extract, count=ndims), 2)
  result = lonarr(ndims, 3)

  case ndims of
    1: begin
        single = 1B
        result[0, *] = mg_hdf_getdata_convertbounds_1d(dimIndices[0], $
                                                       dimensions[0])
      end
    n_elements(dimensions): begin
        single = 0B
        for d = 0L, ndims - 1L do begin
          result[d, *] = mg_hdf_getdata_convertbounds_1d(dimIndices[0], $
                                                         dimensions[0])
        endfor
      end
    else:  message, 'invalid number of dimensions in array indexing notation'
  endcase

  return, result
end


;+
; Compute the `START`, `COUNT`, and `STRIDE` arguments from the bounds.
;
; :Private:
;
; :Params:
;   bounds : in, required, type="lonarr(ndims, 3)"
;     bounds
;
; :Keywords:
;   start : out, optional, type=lonarr(ndims)
;     input for start argument to H5S_SELECT_HYPERSLAB
;   count : out, optional, type=lonarr(ndims)
;     input for count argument to H5S_SELECT_HYPERSLAB
;   stride : out, optional, type=lonarr(ndims)
;     input for stride keyword to H5S_SELECT_HYPERSLAB
;-
pro mg_hdf_getdata_computeslab, bounds, $
                                start=start, count=count, stride=stride
  compile_opt strictarr

  ndims = (size(bounds, /dimensions))[0]

  start = reform(bounds[*, 0])
  stride = reform(bounds[*, 2])

  count = ceil((bounds[*, 1] - bounds[*, 0] + 1L) / float(bounds[*, 2])) > 1
end


;+
; Retrieves an SD variable from an HDF file, scaled appropriately.
;
; :Private:
;
; :Requires:
;   IDL 8.0
;
; :Returns:
;   any
;
; :Params:
;   sd_id : in, required, type=long
;     HDF file identifier
;   varname : in, required, type=string
;     name of variable to retreive from file
;
; :Keywords:
;   bounds : in, optional, type="lonarr(3, ndims) or string"
;     gives start value, end value, and stride for each dimension of the
;     variable
;   error : out, optional, type=long
;     set to a named variable to return the error value; 0 indicates no error
;-
function mg_hdf_getdata_getsdvariable, sd_id, varname, $
                                       bounds=bounds, $
                                       error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, !null
  endif

  index = hdf_sd_nametoindex(sd_id, varname)
  sds_id = hdf_sd_select(sd_id, index)

  hdf_sd_getinfo, sds_id, dims=dims, ndims=ndims
  fullBounds = [[lonarr(ndims)], [dims - 1L], [lonarr(ndims) + 1L]]

  case size(bounds, /type) of
    0 : _bounds = fullBounds
    7 : _bounds = mg_hdf_getdata_convertbounds(bounds, dimensions=dims)
    else: _bounds = transpose(bounds)
  endcase

  mg_hdf_getdata_computeslab, _bounds, $
                              start=start, count=count, stride=stride

  hdf_sd_getdata, sds_id, data, count=count, start=start, stride=stride
  hdf_sd_endaccess, sds_id

  return, data
end


;+
; Helper routine to get attribute data.
;
; :Private:
;
; :Returns:
;   attribute value or `!null` if an error
;
; :Params:
;   sd_id : in, required, type=long
;     netCDF file/dataset identifier
;   variable : in, required, type=string
;     variable name and attribute name string, i.e., "var1.attribute_name"
;
; :Keywords:
;   error : out, optional, type=long
;     set to a named variable to return the error value; 0 indicates no error
;-
function mg_hdf_getdata_getattribute, sd_id, variable, error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, !null
  endif

  tokens = strsplit(variable, '.', /extract)
  var_name = tokens[0]
  attr_name = tokens[1]

  var_index = hdf_sd_nametoindex(sd_id, var_name)
  sds_id = hdf_sd_select(sd_id, var_index)

  att_index = hdf_sd_attrfind(sds_id, attr_name)
  hdf_sd_attrinfo, sds_id, att_index, data=attribute_data

  hdf_sd_endaccess, sds_id

  return, attribute_data
end


;+
; Pulls out a section of a HDF variable.
;
; :Returns:
;   data array
;
; :Params:
;   filename : in, required, type=string
;     filename of the HDF file
;   variable : in, required, type=string
;     variable name (with path if inside a group)
;
; :Keywords:
;   bounds : in, optional, type="lonarr(3, ndims) or string"
;     gives start value, end value, and stride for each dimension of the
;     variable
;   error : out, optional, type=long
;     error value
;-
function mg_hdf_getdata, filename, variable, bounds=bounds, error=error
  compile_opt strictarr
  on_error, 2

  file_id = hdf_sd_start(filename)

  tokens = strsplit(variable, '.', escape='\', count=ndots)

  if (ndots eq 1L) then begin
    ; variable
    bracketPos = strpos(variable, '[')
    if (bracketPos eq -1L) then begin
      _variable = variable
      if (n_elements(bounds) gt 0L) then _bounds = bounds
    endif else begin
      _variable = strmid(variable, 0L, bracketPos)
      closedBracketPos = strpos(variable, ']', /reverse_search)
      _bounds = strmid(variable, bracketPos + 1L, closedBracketPos - bracketPos - 1L)
    endelse

    result = mg_hdf_getdata_getsdvariable(file_id, _variable, $
                                          bounds=_bounds, $
                                          error=error)
    if (error) then message, 'variable not found', /informational
  endif else begin
    ; attribute
    result = mg_hdf_getdata_getattribute(file_id, variable, error=error)
    if (error) then message, 'attribute not found', /informational
  endelse

  hdf_sd_end, file_id

  return, result
end

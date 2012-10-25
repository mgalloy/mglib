; docformat = 'rst'

;+
; Routine for extracting datasets, slices of datasets, or attributes from
; an HDF 5 file with simple notation.
;
; :Todo:
;    better error messages when items not found
;
; :Categories:
;    file i/o, hdf5, sdf
;
; :Examples:
;    An example file is provided with the IDL distribution::
;
;       IDL> f = filepath('hdf5_test.h5', subdir=['examples', 'data'])
;
;    A full dataset can be easily extracted::
;
;       IDL> fullResult = mg_h5_getdata(f, '/arrays/3D int array')
;
;    Slices can also be pulled out::
;
;       IDL> bounds = [[3, 3, 1], [5, 49, 2], [0, 49, 3]]
;       IDL> res1 = mg_h5_getdata(f, '/arrays/3D int array', bounds=bounds)
;       IDL> help, res1
;       RESULT1         LONG      = Array[1, 23, 17]
;
;    Verify that the slice is the same as the slice pulled out of the
;    fullResult::
;
;       IDL> same = array_equal(fullResult[3, 5:*:2, 0:49:3], res1)
;       IDL> print, same ? 'equal' : 'error'
;       equal
;
;    Normal IDL array indexing notation can be used as well::
;
;       IDL> bounds = '3, 5:*:2, 0:49:3'
;       IDL> res2 = mg_h5_getdata(f, '/arrays/3D int array', bounds=bounds)
;       IDL> print, array_equal(res1, res2) ? 'equal' : 'error'
;       equal
;
;    The variable location and bounds can be combined to slice a variable::
;
;       IDL> res3 = mg_h5_getdata(f, '/arrays/3D int array[3, 5:*:2, 0:49:3]')
;       IDL> print, array_equal(res1, res3) ? 'equal' : 'error'
;       equal
;
;    Attributes can be accessed as well::
;
;       IDL> print, mg_h5_getdata(f, '/images/Eskimo.CLASS')
;       IMAGE
;
;    This example is available as a main-level program included in this file::
;
;       IDL> .run mg_h5_getdata
;
; :Author:
;    Michael Galloy
;
; :Copyright:
;    This library is released under a BSD-type license.
;
;    Copyright (c) 2007-2012, Michael Galloy <mgalloy@idldev.com>
;
;    All rights reserved.
;
;    Redistribution and use in source and binary forms, with or without
;    modification, are permitted provided that the following conditions are
;    met:
;
;        a. Redistributions of source code must retain the above copyright
;           notice, this list of conditions and the following disclaimer.
;        b. Redistributions in binary form must reproduce the above copyright
;           notice, this list of conditions and the following disclaimer in
;           the documentation and/or other materials provided with the
;           distribution.
;        c. Neither the name of Michael Galloy nor the names of its
;           contributors may be used to endorse or promote products derived
;           from this software without specific prior written permission.
;
;    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
;    IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
;    THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;    PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
;    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;-

;= Helper routines

;+
; Convert string bounds like `0:*` to a 3-element bounds specification::
;
;    [start_index, stop_index, string]
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
function mg_h5_getdata_convertbounds_1d, sbounds, dim_size
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
function mg_h5_getdata_convertbounds, sbounds, dimensions=dimensions, $
                                      single=single
  compile_opt strictarr
  on_error, 2

  dimIndices = strtrim(strsplit(sbounds, ',', /extract, count=ndims), 2)
  result = lonarr(ndims, 3)

  case ndims of
    1: begin
        single = 1B
        result[0, *] = mg_h5_getdata_convertbounds_1d(dimIndices[0], dimensions[0])
      end
    n_elements(dimensions): begin
        single = 0B
        for d = 0L, ndims - 1L do begin
          result[d, *] = mg_h5_getdata_convertbounds_1d(dimIndices[d], dimensions[d])
        endfor
      end
    else:  message, 'invalid number of dimensions in array indexing notation'
  endcase

  return, result
end


;+
; Compute the H5D_SELECT_HYPERSLAB arguments from the bounds.
;
; :Private:
;
; :Params:
;    bounds : in, required, type="lonarr(ndims, 3)"
;       bounds
;
; :Keywords:
;    start : out, optional, type=lonarr(ndims)
;       input for start argument to H5S_SELECT_HYPERSLAB
;    count : out, optional, type=lonarr(ndims)
;       input for count argument to H5S_SELECT_HYPERSLAB
;    block : out, optional, type=lonarr(ndims)
;       input for block keyword to H5S_SELECT_HYPERSLAB
;    stride : out, optional, type=lonarr(ndims)
;       input for stride keyword to H5S_SELECT_HYPERSLAB
;-
pro mg_h5_getdata_computeslab, bounds, $
                               start=start, count=count, $
                               block=block, stride=stride
  compile_opt strictarr

  ndims = (size(bounds, /dimensions))[0]

  start = reform(bounds[*, 0])
  stride = reform(bounds[*, 2])

  count = ceil((bounds[*, 1] - bounds[*, 0] + 1L) / float(bounds[*, 2]), l64=size(bounds, /type) gt 11) > 1
  block = lonarr(ndims) + 1L
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
;       HDF 5 indentifier of the file
;    variable : in, required, type=string
;       string navigating the path to the dataset
;
; :Keywords:
;    bounds : in, optional, type="lonarr(3, ndims) or string"
;       gives start value, end value, and stride for each dimension of the
;       variable
;    error : out, optional, type=long
;       error value
;    empty : out, optional, type=boolean
;       set to a named variable to return whether the dataset is empty
;-
function mg_h5_getdata_getvariable, fileId, variable, bounds=bounds, $
                                    error=error, empty=empty
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    error = 1L
    return, -1L
  endif

  variableId = h5d_open(fileId, variable)
  variableSpace = h5d_get_space(variableId)

  fullBounds = h5s_get_select_bounds(variableSpace)
  nPoints = h5s_get_select_npoints(variableSpace)

  if (nPoints gt 0L) then begin
    empty = 0B
    sz = size(fullBounds, /dimensions)
    fullBounds = [[fullBounds], [lonarr(sz[0]) + 1L]]
    dimensions = reform(fullBounds[*, 1] - fullBounds[*, 0] + 1L)

    case size(bounds, /type) of
      0 : _bounds = fullBounds
      7 : _bounds = mg_h5_getdata_convertbounds(bounds, dimensions=dimensions, single=single)
      else: _bounds = transpose(bounds)
    endcase

    if (keyword_set(single)) then begin
      ; TODO: implement
      message, 'single-dimension indices not implemented yet'
    endif else begin
      mg_h5_getdata_computeslab, _bounds, $
                                 start=start, count=count, $
                                 block=block, stride=stride
      resultSpace = h5s_create_simple(count)

      h5s_select_hyperslab, variableSpace, start, count, $
                            block=block, stride=stride, /reset
    endelse

    data = h5d_read(variableId, $
                    file_space=variableSpace, $
                    memory_space=resultSpace)
    h5s_close, resultSpace
  endif else begin
    empty = 1B
    data = !null
  endelse

  h5s_close, variableSpace
  h5d_close, variableId

  return, data
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
;    loc : in, required, type=long
;       identifier of group, dataset, or type that contains the attribute
;    attname : in, required, type=string
;       attribute name
;-
function mg_h5_getdata_getattributedata, loc, attname
  compile_opt strictarr
  on_error, 2

  att = h5a_open_name(loc, attname)
  result = h5a_read(att)
  h5a_close, att

  return, result
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
;       HDF 5 file identifier of the file to read
;    variable : in, required, type=string
;       path to attribute using "/" to navigate groups/datasets and "." to
;       indicate the attribute name
;
; :Keywords:
;    error : out, optional, type=long
;       error value
;-
function mg_h5_getdata_getattribute, fileId, variable, error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    error = 1L
    return, -1L
  endif

  tokens = strsplit(variable, '.', escape='\', count=ndots)
  dotpos = tokens[1L] - 1L

  loc = strmid(variable, 0, dotpos)
  attname = strmid(variable, dotpos + 1L)
  objInfo = h5g_get_objinfo(fileId, loc)

  result = -1L

  case objInfo.type of
    'LINK': message, 'Cannot handle an attribute of a reference'
    'GROUP': begin
        group = h5g_open(fileId, loc)
        result = mg_h5_getdata_getattributedata(group, attname)
        h5g_close, group
      end
    'DATASET': begin
        dataset = h5d_open(fileId, loc)
        result = mg_h5_getdata_getattributedata(dataset, attname)
        h5d_close, dataset
      end
    'TYPE': begin
        type = h5t_open(fileId, loc)
        result = mg_h5_getdata_getattributedata(type, attname)
        h5t_close, type
      end
    'UNKNOWN': message, 'Unknown item'
  endcase

  return, result
end


;= Main routine

;+
; Pulls out a section of a HDF5 variable.
;
; :Returns:
;    data array
;
; :Params:
;    filename : in, required, type=string
;       filename of the HDF5 file
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
function mg_h5_getdata, filename, variable, bounds=bounds, error=error
  compile_opt strictarr
  on_error, 2

  if (n_elements(filename) eq 0L) then message, 'no filename specified'
  if (~file_test(filename)) then begin
    message, string(filename, format='(%"filename ''%s'' not found")')
  endif
  if (n_elements(variable) eq 0L) then message, 'no variable requested'

  fileId = h5f_open(filename)

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

    result = mg_h5_getdata_getvariable(fileId, _variable, bounds=_bounds, $
                                       error=error, empty=empty)
    if (error && ~arg_present(error)) then begin
      message, 'variable not found', /informational
    endif
  endif else begin
    ; attribute
    result = mg_h5_getdata_getattribute(fileId, variable, error=error)
    if (error && ~arg_present(error)) then begin
      message, 'attribute not found', /informational
    endif
  endelse

  h5f_close, fileId

  return, result
end


; main-level example program

f = filepath('hdf5_test.h5', subdir=['examples', 'data'])

; full result is lonarr(10, 50, 100)
fullResult = mg_h5_getdata(f, '/arrays/3D int array')

; pull out a slice of the full result
bounds = [[3, 3, 1], [5, 49, 2], [0, 49, 3]]
res1 = mg_h5_getdata(f, '/arrays/3D int array', bounds=bounds)
help, res1

; compare indexing into fullResult versus slice pulled out
same = array_equal(fullResult[3, 5:*:2, 0:49:3], res1)
print, same ? 'equal' : 'error'

; specify the same bounds with a string
bounds = '3, 5:*:2, 0:49:3'
res2 = mg_h5_getdata(f, '/arrays/3D int array', bounds=bounds)
print, array_equal(res1, res2) ? 'equal' : 'error'

; again the same slice, but with even nicer notation
res3 = mg_h5_getdata(f, '/arrays/3D int array[3, 5:*:2, 0:49:3]')
print, array_equal(res1, res3) ? 'equal' : 'error'

; grab an attribute
print, mg_h5_getdata(f, '/images/Eskimo.CLASS')

end
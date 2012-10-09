; docformat = 'rst'

;+
; This class represents a variable in an HDF5 file.
;
; :Categories:
;    file i/o, hdf5, sdf
;
; :Examples:
;    Try::
;
;       IDL> h = mg_h5(file_which('hdf5_test.h5'))
;       IDL> g1 = h.images
;       IDL> e = g1.eskimo
;       IDL> help, e
;       E               H5BYTE    = Array[600, 649]
;       IDL> help, size(e, /structure), /structures
;       ** Structure IDL_SIZE, 8 tags, length=80, data length=80:
;          TYPE_NAME       STRING    'OBJREF'
;          STRUCTURE_NAME  STRING    ''
;          TYPE            INT             11
;          FILE_LUN        INT              0
;          FILE_OFFSET     LONG                 0
;          N_ELEMENTS      LONG            389400
;          N_DIMENSIONS    LONG                 2
;          DIMENSIONS      LONG      Array[8]
;       IDL> plot, e[*, 400], xstyle=9, ystyle=8
;       IDL> print, e.image_colormodel, format='(%"IMAGE_COLORMODEL attribute = %s")'
;       IMAGE_COLORMODEL attribute = RGB
;       IDL> print, e['IMAGE_COLORMODEL'], format='(%"IMAGE_COLORMODEL attribute = %s")'
;       IMAGE_COLORMODEL attribute = RGB
;
; :Requires:
;    IDL 8.0
;
; :Author:
;    Michael Galloy
;-


;+
; Get properties
;-
pro mgffh5dataset::getProperty, _ref_extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->MGffH5Base::getProperty, _extra=e
end


;+
; Opens the file.
;
; :Private:
;
; :Keywords:
;    error : out, optional, type=long
;       error code, 0 indicates no error
;-
pro mgffh5dataset::_open, error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return
  endif

  self.parent->getProperty, identifier=parent_id
  self.id = h5d_open(parent_id, self.name)
end


;+
; Close the file.
;
; :Private:
;
; :Keywords:
;    error : out, optional, type=long
;       error code, 0 indicates no error
;-
pro mgffh5dataset::_close, error=error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return
  endif

  h5d_close, self.id
end


;+
; Helper method to determine the dimensions of the data set.
;
; :Private:
;
; :Returns:
;    lonarr
;-
function mgffh5dataset::_getDimensions
  compile_opt strictarr

  variableSpace = h5d_get_space(self.id)

  fullBounds = h5s_get_select_bounds(variableSpace)
  sz = size(fullBounds, /dimensions)
  fullBounds = [[fullBounds], [lonarr(sz[0]) + 1L]]
  dimensions = reform(fullBounds[*, 1] - fullBounds[*, 0] + 1L)

  h5s_close, variableSpace

  return, dimensions
end


;+
; Helper method to determine the IDL type (using the codes used by SIZE) of
; the data set.
;
; :Private:
;
; :Returns:
;    long
;-
function mgffh5dataset::_getIdlType
  compile_opt strictarr

  typeId = h5d_get_type(self.id)

  idlType = h5t_idltype(typeId)
  h5t_close, typeId

  return, idlType
end


;+
; Operator overloading method for returning information from SIZE.
;
; :Returns:
;    lonarr
;
; :Examples:
;    Try::
;
;       IDL> h = mg_h5(file_which('hdf5_test.h5'))
;       IDL> g = h.images
;       IDL> print, size(g.eskimo)
;                  2         600         649          11      389400
;-
function mgffh5dataset::_overloadSize
  compile_opt strictarr

  return, self->_getDimensions()
end


;+
; Overload method for HELP routine output. Returns information about data as
; a normal array, but tacks on 'H5' to the data type.
;
; :Returns:
;    string
;
; :Params:
;    varname : in, required, type=string
;       variable's name so that it can be placed into the output
;-
function mgffh5dataset::_overloadHelp, varname
  compile_opt strictarr

  sdims = strjoin(strtrim(self->_getDimensions(), 2), ', ')
  type = mg_h5_typedecl(self->_getIdlType())
  specs = string(self.name, sdims, format='(%"H5Dataset:%s[%s]")')

  return, self->MGffH5Base::_overloadHelp(varname, type=type, specs=specs)
end


;+
; Overload method for `PRINT` routine output. Returns entire data array.
;
; :Returns:
;    numeric array
;-
function mgffh5dataset::_overloadPrint
  compile_opt strictarr

  dims = self->_getDimensions()
  case 1 of
    n_elements(dims) eq 8: return, self[*, *, *, *, *, *, *, *]
    n_elements(dims) eq 7: return, self[*, *, *, *, *, *, *]
    n_elements(dims) eq 6: return, self[*, *, *, *, *, *]
    n_elements(dims) eq 5: return, self[*, *, *, *, *]
    n_elements(dims) eq 4: return, self[*, *, *, *]
    n_elements(dims) eq 3: return, self[*, *, *]
    n_elements(dims) eq 2: return, self[*, *]
    n_elements(dims) eq 1: return, self[*]
  endcase
end


;+
; Convert the parameters needed by H5S_SELECT_HYPERSLAB.
;
; :Params:
;    bounds : in, required, type="lonarr(ndims, 3)"
;       bounds in the form of `[start, stop, stride]` indices
;
; :Keywords:
;    start : out, optional, type=lonarr(ndims)
;    count : out, optional, type=lonarr(ndims)
;    block : out, optional, type=lonarr(ndims)
;    stride : out, optional, type=lonarr(ndims)
;-
pro mgffh5dataset::_computeslab, bounds, $
                                 start=start, count=count, $
                                 block=block, stride=stride
  compile_opt strictarr
  on_error, 2

  ndims = (size(bounds, /dimensions))[0]

  start = reform(bounds[*, 0])
  stride = reform(bounds[*, 2])

  count = ceil((bounds[*, 1] - bounds[*, 0] + 1L) / float(bounds[*, 2])) > 1
  block = lonarr(ndims) + 1L
end


;+
; Helper method to convert information about a dimension's range into a three
; element vector: `[start, stop, stride]`.
;
; :Params:
;    isRange : in, required, type=boolean
;       boolean indicating whether the dimension is a range or a single index
;    bounds : in, required, type=long/lonarr(3)
;       if `isRange` is set then bounds will be a `lonarr(3)` specifying
;       `[start, stop, stride]` (with -1 in the `stop` position indicating to
;       to continue to the end of the dimension); if `isRange` is not set then
;       bounds will be a single index
;
; :Keywords:
;    dimensions
;-
function mgffh5dataset::_convertbounds, isRange, bounds, dimensions=dimensions
  compile_opt strictarr
  on_error, 2

  if (~isRange) then return, [bounds, bounds, 1L]

  result = bounds
  if (result[1] eq -1L) then result[1] = dimensions - 1L

  return, result
end


;+
; Get value of attribute.
;
; :Returns:
;    attribute value
;
; :Params:
;    name : in, required, type=string
;       name of attribute
;-
function mgffh5dataset::readAttribute, name
  compile_opt strictarr
  on_error, 2

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    message, 'attribute not found'
  endif

  att = h5a_open_name(self.id, name)
  result = h5a_read(att)
  h5a_close, att

  return, result
end


;+
; Operator overloading methods for retrieving subsets of the dataset. Also
; will retrieve an attribute if indexed by the attribute name as a string
; (useful to specifiy an attribute name case-sensitively).
;
; :Examples:
;    Try::
;
;       IDL> h = mg_h5(file_which('hdf5_test.h5'))
;       IDL> g = h.images
;       IDL> e = g.eskimo
;       IDL> plot, e[*, 400], xstyle=9, ystyle=8
;
; :Returns:
;    numeric array
;
; :Params:
;    isRange : in, required, type=lonarr
;       lonarr with 1-8 elements, 1 for each dimension specified in the
;       indexing operation, indicating whether the corresponding dimension
;       is a range or single value
;    ss1 : in, required, type=long/lonarr(3)
;       subscripts for 1st dimension
;    ss2 : in, optional, type=long/lonarr(3)
;       subscripts for 2nd dimension
;    ss3 : in, optional, type=long/lonarr(3)
;       subscripts for 3rd dimension
;    ss4 : in, optional, type=long/lonarr(3)
;       subscripts for 4th dimension
;    ss5 : in, optional, type=long/lonarr(3)
;       subscripts for 5th dimension
;    ss6 : in, optional, type=long/lonarr(3)
;       subscripts for 6th dimension
;    ss7 : in, optional, type=long/lonarr(3)
;       subscripts for 7th dimension
;    ss8 : in, optional, type=long/lonarr(3)
;       subscripts for 8th dimension
;-
function mgffh5dataset::_overloadBracketsRightSide, isRange, $
                                                    ss1, ss2, ss3, ss4, $
                                                    ss5, ss6, ss7, ss8
  compile_opt strictarr
  on_error, 2

  if (size(ss1, /type) eq 7) then return, self->readAttribute(ss1)

  variableSpace = h5d_get_space(self.id)

  fullBounds = h5s_get_select_bounds(variableSpace)
  sz = size(fullBounds, /dimensions)
  fullBounds = [[fullBounds], [lonarr(sz[0]) + 1L]]
  dimensions = reform(fullBounds[*, 1] - fullBounds[*, 0] + 1L)

  if ((n_elements(isRange) eq 1L) && (sz[0] ne 1L) && (array_equal(ss1, [0, -1, 1]))) then begin
    ; asking for all the elements
    _bounds = fullBounds
  endif else begin
    _bounds = lonarr(n_elements(isRange), 3)
    switch 1 of
      n_elements(ss8) gt 0L: begin
          _bounds[7, *] = self->_convertbounds(isRange[7], ss8, $
                                               dimensions=dimensions[7])
        end
      n_elements(ss7) gt 0L: begin
          _bounds[6, *] = self->_convertbounds(isRange[6], ss7, $
                                               dimensions=dimensions[6])
        end
      n_elements(ss6) gt 0L: begin
          _bounds[5, *] = self->_convertbounds(isRange[5], ss6, $
                                               dimensions=dimensions[5])
        end
      n_elements(ss5) gt 0L: begin
          _bounds[4, *] = self->_convertbounds(isRange[4], ss5, $
                                               dimensions=dimensions[4])
        end
      n_elements(ss4) gt 0L: begin
          _bounds[3, *] = self->_convertbounds(isRange[3], ss4, $
                                               dimensions=dimensions[3])
        end
      n_elements(ss3) gt 0L: begin
          _bounds[2, *] = self->_convertbounds(isRange[2], ss3, $
                                               dimensions=dimensions[2])
        end
      n_elements(ss2) gt 0L: begin
          _bounds[1, *] = self->_convertbounds(isRange[1], ss2, $
                                               dimensions=dimensions[1])
        end
      n_elements(ss1) gt 0L: begin
          _bounds[0, *] = self->_convertbounds(isRange[0], ss1, $
                                               dimensions=dimensions[0])
        end
    endswitch
  endelse

  self->_computeslab, _bounds, $
                      start=start, count=count, $
                      block=block, stride=stride

  resultSpace = h5s_create_simple(count)

  h5s_select_hyperslab, variableSpace, start, count, $
                        block=block, stride=stride, /reset

  data = h5d_read(self.id, $
                  file_space=variableSpace, $
                  memory_space=resultSpace)

  h5s_close, resultSpace
  h5s_close, variableSpace

  return, data
end


;+
; Free resources.
;-
pro mgffh5dataset::cleanup
  compile_opt strictarr

  self->_close
end


;+
; Create an HDF5 dataset.
;
; :Returns:
;    1 for success, 0 for failure
;
; :Keywords:
;    error : out, optional, type=long
;       error code, 0 indicates no error
;-
function mgffh5dataset::init, error=error, _extra=e
  compile_opt strictarr
  on_error, 2

  if (~self->MGffH5Base::init(_extra=e)) then return, 0

  self->_open, error=error
  if (error ne 0L) then message, 'invalid HDF5 dataset'

  return, 1
end


;+
; Define instance variables and class inheritance.
;-
pro mgffh5dataset__define
  compile_opt strictarr

  define = { MGffH5Dataset, inherits MGffH5Base }
end

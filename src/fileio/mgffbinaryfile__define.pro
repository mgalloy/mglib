; docformat = 'rst'


;+
; Object representing a binary file.
;
; :Properties:
;   dimensions
;     dimensions of data in file
;   filename
;     filename of binary file
;   read
;     set to indicate the file is read only
;   size
;     size in bytes of file
;   type
;     `SIZE` type code of data in file
;   write
;     set to indicate the file is writable
;-


;= Operator overloaded methods

;+
; Returns a string describing the binary file object. Called by the `HELP`
; routine.
;
; :Returns:
;   string
;
; :Params:
;   varname : in, required, type=string
;     name of the variable to use when outputting help information
;-
function mgffbinaryfile::_overloadHelp, varname
  compile_opt strictarr

  format = '(%"%-15s %-9s = BinaryFile <%s>")'
  type = size(fix(0, type=self.type), /tname)
  return, string(varname, type, self.filename, format=format)
end


;+
; Allows array index access with brackets.
;
; :Returns:
;   array of type given by `TYPE` property
;
; :Params:
;   isRange : in, required, type=lonarr(8)
;     indicates whether the i-th parameter is a index range or a scalar/array
;     of indices
;   ss1 : in, required, type=long/lonarr
;     scalar subscript index value, an index array, or a subscript range
;   ss2 : in, optional, type=long/lonarr
;     scalar subscript index value, an index array, or a subscript range
;   ss3 : in, optional, type=long/lonarr
;     scalar subscript index value, an index array, or a subscript range
;   ss4 : in, optional, type=long/lonarr
;     scalar subscript index value, an index array, or a subscript range
;   ss5 : in, optional, type=long/lonarr
;     scalar subscript index value, an index array, or a subscript range
;   ss6 : in, optional, type=long/lonarr
;     scalar subscript index value, an index array, or a subscript range
;   ss7 : in, optional, type=long/lonarr
;     scalar subscript index value, an index array, or a subscript range
;   ss8 : in, optional, type=long/lonarr
;     scalar subscript index value, an index array, or a subscript range
;-
function mgffbinaryfile::_overloadBracketsRightSide, isRange, $
                                                     ss1, ss2, ss3, ss4, $
                                                     ss5, ss6, ss7, ss8
  compile_opt strictarr
  on_error, 2

  if (~self.read) then message, 'file not opened for reading'
  if (self.type lt 0L) then message, 'type not set'
  if (self.ndimensions lt 0L) then message, 'dimensions not set'

  ; TODO: implement
end


;+
; Allows setting values of the binary file by array index.
;
; :Params:
;   objref : in, required, type=objref
;     should be self
;   value : in, required, type=any
;     value to assign to the array list
;   isRange : in, required, type=lonarr(8)
;     indicates whether the i-th parameter is a index range or a scalar/array
;     of indices
;   ss1 : in, required, type=long/lonarr
;     scalar subscript index value, an index array, or a subscript range
;   ss2 : in, optional, type=any
;     not used
;   ss3 : in, optional, type=any
;     not used
;   ss4 : in, optional, type=any
;     not used
;   ss5 : in, optional, type=any
;     not used
;   ss6 : in, optional, type=any
;     not used
;   ss7 : in, optional, type=any
;     not used
;   ss8 : in, optional, type=any
;     not used
;-
pro mgffbinaryfile::_overloadBracketsLeftSide, objref, value, isRange, $
                                               ss1, ss2, ss3, ss4, $
                                               ss5, ss6, ss7, ss8
  compile_opt strictarr
  on_error, 2

  if (~self.write) then message, 'file not opened for writing'

  ; TODO: implement
end


;= Property methods

;+
; Get properties.
;-
pro mgffbinaryfile::getProperty, filename=filename, type=type, size=size
  compile_opt strictarr

  if (arg_present(filename)) then filename = self.filename
  if (arg_present(type)) then type = self.type
  if (arg_present(size)) then begin
    info = fstat(self.lun)
    size = info.size
  endif
end


;+
; Set properties.
;-
pro mgffbinaryfile::setProperty, filename=filename, $
                                 type=type, dimensions=dimensions, $
                                 read=read, write=write
  compile_opt strictarr

  if (n_elements(read) gt 0L) then self.read = keyword_set(read)
  if (n_elements(write) gt 0L) then self.write = keyword_set(write)

  if (n_elements(filename) gt 0L) then begin
    self.filename = filename

    if (self.lun gt 0L) then free_lun, self.lun

    case 1 of
      self.read && self.write: openu, lun, self.filename, /get_lun
      self.write: openw, lun, self.filename, /get_lun
      else: openr, lun, self.filename, /get_lun
    endcase

    self.lun = lun
  endif

  if (n_elements(dimensions) gt 0L) then begin
    *self.dimensions = dimensions
    self.ndimensions = n_elements(dimensions)
  endif

  if (n_elements(type) gt 0L) then begin
    self.type = type
    self.type_size = mg_typesize(self.type)
  endif
end


;= helper routines

;+
; Read data from binary file.
;
; :Returns:
;   array of type `TYPE`
;
; :Keywords:
;   type : in, optional, type=integer, default=TYPE property
;     `SIZE` type code of returned array
;   dimensions : in, optional, type=lonarr, default=DIMENSIONS property
;     dimensions of returned array
;-
function mgffbinaryfile::read, type=type, dimensions=dimensions
  compile_opt strictarr

  if (~self.read) then message, 'file not opened for reading'

  _type = n_elements(type) eq 0L ? self.type : type

  if (n_elements(dimensions) eq 0L) then begin
    info = fstat(self.lun)
    if (product(*self.dimensions) le (info.size - info.cur_ptr + 1L)) then begin
      _dimensions = *self.dimensions
    endif else begin
      _dimensions = [(info.size - info.cur_ptr + 1L) / mg_typesize(_type)]
    endelse
  endif else begin
    _dimensions = dimensions
  endelse

  result = make_array(type=_type, dimension=_dimensions)

  readu, self.lun, result

  return, result
end


;= Lifecycle methods

;+
; Free resources.
;-
pro mgffbinaryfile::cleanup
  compile_opt strictarr

  if (self.lun gt 0L) then free_lun, self.lun
  ptr_free, self.dimensions

  self->IDL_Object::cleanup
end


;+
; Create binary file object.
;
; :Returns:
;   1 for success, 0 otherwise
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     properties
;-
function mgffbinaryfile::init, _extra=e
  compile_opt strictarr

  if (~self->IDL_Object::init()) then return, 0

  ; set defaults
  self.lun = -1L
  self.type = -1L
  self.type_size = 0L
  self.dimensions = ptr_new(/allocate_heap)
  self.ndimensions = -1L

  self->setProperty, _extra=e

  return, 1
end


;+
; Define instance variables.
;-
pro mgffbinaryfile__define
  compile_opt strictarr

  define = { MGffBinaryFile, inherits IDL_Object, $
             filename: '', $
             lun: 0L, $
             type: 0L, $
             type_size: 0L, $
             dimensions: ptr_new(), $
             ndimensions: 0L, $
             read: 0B, $
             write: 0B $
           }
end

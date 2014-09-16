; docformat = 'rst'


;= Operator overloaded methods

;+
; Returns a string describing the text file object. Called by the `HELP`
; routine.
;
; :Returns:
;   string
;
; :Params:
;   varname : in, required, type=string
;     name of the variable to use when outputting help information
;-
function mgfftextfile::_overloadHelp, varname
  compile_opt strictarr

  format = '(%"%-15s %-9s = TextFile <%s>")'
  return, string(varname, 'ASCII', self.filename, format=format)
end


;+
; Allows array index access with brackets.
;
; :Returns:
;   `strarr`
;
; :Params:
;   isRange : in, required, type=lonarr(8)
;     indicates whether the i-th parameter is a index range or a scalar/array
;     of indices
;   ss1 : in, required, type=long/lonarr
;     scalar subscript index value, an index array, or a subscript range
;-
function mgfftextfile::_overloadBracketsRightSide, isRange, ss1
  compile_opt strictarr
  on_error, 2

  if (~self.read) then message, 'file not opened for reading'

  nlines = file_lines(self.filename)
  if (isRange[0]) then begin
    ss1[0] = ss1[0] lt 0L ? (nlines + ss1[0]) : ss1[0]
    ss1[1] = ss1[1] lt 0L ? (nlines + ss1[1]) : ss1[1]
  endif else begin
    ind = where(ss1 lt 0L, count)
    if (count gt 0L) then begin
      ss1[ind] = nlines + ss1[ind]
    endif
  endelse

  ; read data up to the last line required
  data = strarr(max(ss1) + 1L)

  point_lun, self.lun, 0
  readf, self.lun, data

  if (isRange[0]) then begin
    return, data[ss1[0]:ss1[1]:ss1[2]]
  endif else begin
    return, data[ss1]
  endelse
end


;+
; Allows setting values of the text file by array index.
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
pro mgfftextfile::_overloadBracketsLeftSide, objref, value, isRange, $
                                             ss1, ss2, ss3, ss4, $
                                             ss5, ss6, ss7, ss8
  compile_opt strictarr
  on_error, 2

  if (~self.write) then message, 'file not opened for writing'

  ; TODO: implement
  message, 'not implemented'
end


;+
; Allows a text file to be used in a `FOREACH` loop.
;
; :Returns:
;   1 if there is an item to return, 0 if not
;
; :Params:
;   line : out, required, type=list type
;     value to return as the loop
;   file_ptr : in, out, optional, type=undefined/long
;     `file_ptr` is undefined for first element, otherwise the index of the
;     last element returned
;-
function mgfftextfile::_overloadForeach, line, file_ptr
  compile_opt strictarr
  on_error, 2

  ; start 0 bytes into the file
  file_ptr = n_elements(file_ptr) eq 0L ? 0L : file_ptr
  point_lun, self.lun, file_ptr

  ; return if we're at the end of the file
  if (eof(self.lun)) then return, 0

  ; read the line at that location
  line = ''
  readf, self.lun, line

  ; remember the current file pointer
  point_lun, - self.lun, file_ptr

  return, 1
end


;= Property methods

;+
; Set properties.
;
; :Keywords:
;   filename : in, optional, type=string
;     filename of text file
;   read : in, optional, type=boolean
;     set to indicate the text file is read only
;   write : in, optional, type=boolean
;     set to indicate the text file is writable
;-
pro mgfftextfile::setProperty, filename=filename, read=read, write=write
  compile_opt strictarr

  if (n_elements(read) gt 0L) then self.read = keyword_set(read)
  if (n_elements(write) gt 0L) then self.write = keyword_set(write)

  if (n_elements(filename) gt 0L) then begin
    self.filename = filename

    if (self.lun gt 0L) then free_lun, self.lun

    case 1 of
      self.read && self.write: openu, lun, self.filename, /get_lun
      self.write: openw, lun, self.filename, /get_lun
      else: begin
          self.read = 1B
          openr, lun, self.filename, /get_lun
        end
    endcase

    self.lun = lun
  endif
end


;+
; Get properties.
;-
pro mgfftextfile::getProperty
  compile_opt strictarr

end


;= Lifecycle methods

;+
; Create a text file object.
;
; :Returns:
;   1 if successful, 0 otherwise
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     properties
;-
function mgfftextfile::init, _extra=e
  compile_opt strictarr

  if (~self->IDL_Object::init()) then return, 0

  self->setProperty, _extra=e

  return, 1
end


;+
; Define instance variables of text file object.
;
; :Fields:
;   filename
;     filename of text file
;   lun
;     logical unit number for text file
;   read
;     set if file open for reading
;   write
;     set if file open for writing
;-
pro mgfftextfile__define
  compile_opt strictarr

  define = { MGffTextFile, inherits IDL_Object, $
             filename:'', $
             lun: 0L, $
             read: 0B, $
             write: 0B $
           }
end

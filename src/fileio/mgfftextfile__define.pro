; docformat = 'rst'


;= Operator overloaded methods

function mgfftextfile::_overloadHelp, varname
  compile_opt strictarr

  format = '(%"%-15s %-9s = TextFile <%s>")'
  return, string(varname, 'ASCII', self.filename, format=format)
end


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


pro mgfftextfile::_overloadBracketsLeftSide, objref, value, isRange, $
                                             ss1, ss2, ss3, ss4, $
                                             ss5, ss6, ss7, ss8
  compile_opt strictarr
  on_error, 2

  if (~self.write) then message, 'file not opened for writing'

  ; TODO: implement
  message, 'not implemented'
end


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


pro mgfftextfile::getProperty
  compile_opt strictarr

end


;= Lifecycle methods

function mgfftextfile::init, _extra=e
  compile_opt strictarr

  if (~self->IDL_Object::init()) then return, 0

  self->setProperty, _extra=e

  return, 1
end


;+
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

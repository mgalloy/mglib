; docformat = 'rst'

;+
; Represents a file.
;-


;+
; Read portions of a file using bracket notation in IDL 8.0.
;
; :Returns:
;    `bytarr`
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
function mgfffile::_overloadBracketsRightSide, isRange, $
                                               ss1, ss2, ss3, ss4, $
                                               ss5, ss6, ss7, ss8
  compile_opt strictarr

  openr, lun, self.filename, /get_lun

  if (isRange[0]) then begin
    point_lun, lun, ss1[0]
    dim = (ss1[1] lt 0L ? (self.size + ss1[1]) : ss1[1]) - ss1[0] + 1
    data = bytarr(dim)
    readu, lun, data
  endif else begin
    data = bytarr(n_elements(ss1))
    element = 0B
    for el = 0L, n_elements(ss1) - 1L do begin
      point_lun, lun, ss1[el]
      readu, lun, element
      data[el] = element
    endfor
  endelse

  free_lun, lun
  return, data
end


;+
; Get properties.
;-
pro mgfffile::getProperty, filename=filename, exists=exists, read=read, write=write, $
                           execute=execute, regular=regular, $
                           directory=directory, block_special=blockSpecial, $
                           character_special=characterSpecial, $
                           named_pipe=namedPipe, $
                           setgid=setgid, setuid=setuid, $
                           socket=socket, sticky_bit=stickyBit, $
                           symlink=symlink, dangling_symlink=danglingSymlink, $
                           atime=atime, ctime=ctime, mtime=mtime, size=size
  compile_opt strictarr

  if (arg_present(filename)) then filename = self.filename
  if (arg_present(exists)) then exists = self.exists
  if (arg_present(read)) then read = self.read
  if (arg_present(write)) then write = self.write
  if (arg_present(execute)) then execute = self.execute
  if (arg_present(regular)) then regular = self.regular
  if (arg_present(directory)) then directory = self.directory
  if (arg_present(blockSpecial)) then blockSpecial = self.blockSpecial
  if (arg_present(characterSpecial)) then characterSpecial = self.characterSpecial
  if (arg_present(namedPipe)) then namedPipe = self.namedPipe
  if (arg_present(setgid)) then setgid = self.setgid
  if (arg_present(setuid)) then setuid = self.setuid
  if (arg_present(socket)) then socket = self.socket
  if (arg_present(stickyBit)) then stickyBit = self.stickyBit
  if (arg_present(symlink)) then symlink = self.symlink
  if (arg_present(danglingSymlink)) then danglingSymlink = self.danglingSymlink
  if (arg_present(atime)) then atime = self.atime
  if (arg_present(ctime)) then ctime = self.ctime
  if (arg_present(mtime)) then mtime = self.mtime
  if (arg_present(size)) then size = self.size
end


;+
; Read binary data from the file.
;
; :Returns:
;    array
;
; :Keywords:
;    type : in, optional, type=long, default=1L
;       `SIZE` type code for data to read
;    dimension : in, required, type=lonarr
;       dimensions of the array to read, defaults to full size of file (after
;       any `OFFSET` is skipped)
;    offset : in, optional, type=long
;       number of bytes to skip before reading
;-
function mgfffile::readu, type=type, dimension=dimension, offset=offset
  compile_opt strictarr

  _offset = n_elements(offset) eq 0L ? 0L : offset
  _type = n_elements(type) eq 0L ? 1L : type

  _dimension = n_elements(dimension) eq 0L $
                 ? (self.size / mg_typesize(_type) - _offset) $
                 : dimension

  data = make_array(dimension=_dimension, type=_type)

  openr, lun, self.filename, /get_lun
  point_lun, lun, _offset
  readu, lun, data
  free_lun, lun

  return, data
end


;+
; Read the file into a string array, or a single string if `SINGLE` is set.
;
; :Returns:
;    string, strarr
;
; :Keywords:
;    single : in, optional, type=boolean
;-
function mgfffile::readf, single=single
  compile_opt strictarr

  nlines = file_lines(self.filename)
  result = strarr(nlines)
  openr, lun, self.filename, /get_lun
  readf, lun, result
  free_lun, lun

  return, keyword_set(single) ? mg_strmerge(result) : result
end


;+
; Create a file object.
;
; :Returns:
;    1 if successful, 0 if failure
;
; :Params:
;    filename : in, required, type=string
;       filename of file
;-
function mgfffile::init, filename
  compile_opt strictarr

  self.filename = filename
  struct_assign, file_info(self.filename), self, /nozero

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    filename
;       full filename
;-
pro mgfffile__define
  compile_opt strictarr

  define = { MGffFile, inherits file_info, inherits IDL_Object, filename: '' }
end


; main-level example

f = mgfffile(file_which('ascii.txt'))

print, f.filename, format='(%"Filename: %s")'
print, systime(0, f.atime), format='(%"File was last accessed: %s")'
print, f.size, format='(%"File size: %d bytes")'
print

lines = f->readf()
full_text = string(f->readu())
first100chars = f[0:99]

end


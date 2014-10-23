; docformat = 'rst'

;+
; This class represents a filename (or directory name).
;
; This class corrects many of the errors found in `FILEPATH`, `FILE_DIRNAME`,
; and `FILE_BASENAME`.
;
; :Properties:
;   dirname
;     characters before the last path separator in the filename; empty if no
;     path separator
;   directories
;     array of directories as listed in dirname
;   basename
;     characters after the last path separator in the filename; the entire
;     filename if no path separator
;   extension
;     characters after the last dot in the basename
;-


;= property access

;+
; Get properties.
;-
pro mgfffilename::getProperty, extension=extension, basename=basename, $
                               dirname=dirname, directories=directories
  compile_opt strictarr

  seppos = strpos(self.filename, path_sep(), /reverse_search)

  if (arg_present(basename) || arg_present(extension)) then begin
    basename = seppos eq -1L ? $
                 self.filename $
                 : strmid(self.filename, seppos + 1L)
  endif

  if (arg_present(dirname) || arg_present(directories)) then begin
    dirname = seppos eq -1L ? '.' : strmid(self.filename, 0, seppos)
    dirname += path_sep()
  endif

  if (arg_present(directories)) then begin
    directories = strsplit(dirname, path_sep(), /extract)
  endif

  if (arg_present(extension)) then begin
    dotpos = strpos(basename, '.', /reverse_search)
    extension = dotpos eq -1L ? '' : strmid(basename, dotpos + 1L)
  endif
end


;+
; Set properties.
;-
pro mgfffilename::setProperty, extension=extension
  compile_opt strictarr

  if (n_elements(extension) gt 0L) then begin
    seppos = strpos(self.filename, path_sep(), /reverse_search)
    basename = seppos eq -1L ? $
                 self.filename $
                 : strmid(self.filename, seppos + 1L)
    dotpos = strpos(basename, '.', /reverse_search)
    self.filename = dotpos eq -1L $
                      ? (self.filename + '.' + extension) $
                      : (strmid(self.filename, 0, seppos + 1L) $
                           + strmid(basename, 0, dotpos + 1L) $
                           + extension)
  endif
end


;= public interface

;+
; Create a filename by specifying its parts. Parts are assumed to be empty if
; not specified (unlike `FILEPATH`).
;
; :Params:
;   basename : in, optional, type=string, default=''
;     basename or full filename of filename
;
; :Keywords:
;   clock_basename : in, optional, type=boolean
;     set to use `basename` as a C-style format string to insert the number
;     of milliseconds since 1 January 1970 into
;   subdirectory : in, optional, type=string/strarr, default=''
;     subdirectory or subdirectories
;   root_dir : in, optional, type=string, default=''
;     root directory
;   tmp : in, optional, type=boolean
;     set to ignore `ROOT_DIR` keyword and use a root directory specially
;     designated for temporary files
;-
pro mgfffilename::compose, basename, clock_basename=clockBasename, $
                           subdirectory=subdirectory, $
                           tmp=tmp, root_dir=rootDir
  compile_opt strictarr

  if (keyword_set(tmp)) then begin
    _root = getenv('IDL_TMPDIR')
  endif else _root = n_elements(rootDir) eq 0L ? '' : rootDir

  ; add path_sep() to the end of the root if not there already
  if (strlen(_root) gt 0L $
        && strmid(_root, strlen(_root) - 1L) ne path_sep()) then begin
    _root += path_sep()
  endif

  _subdir = n_elements(subdirectory) eq 0L $
              ? '' $
              : (strjoin(subdirectory, path_sep()) + path_sep())

  _basename = n_elements(basename) eq 0L ? '' : basename

  if (keyword_set(clockBasename)) then begin
    t = 1000.D * systime(/seconds)
    _basename = string(t, format='(%"' + _basename + '-%d")')
  endif

  self.filename = _root + _subdir + _basename
end


;+
; Returns the filename as a string.
;
; :Returns:
;   string
;
; :Keywords:
;   format : in, optional, type=string
;     format string with a single string specifier in it (%s or A, depending
;     on the format type) in it
;-
function mgfffilename::toString, format=format
  compile_opt strictarr

  return, string(self.filename, format=format)
end


;= lifecycle methods

;+
; Free resources.
;-
pro mgfffilename::cleanup
  compile_opt strictarr

end


;+
; Create a filename object.
;
; :Returns:
;   1 for success, 0 otherwise
;
; :Params:
;   basename : in, optional, type=string
;     basename or full filename of the new filename object
;
; :Keywords:
;   _ref_extra : in, out, optional, type=keywords
;     input keywords to ::compose and output keywords to ::getProperty
;-
function mgfffilename::init, basename, _ref_extra=e
  compile_opt strictarr

  self->compose, basename, _extra=e
  self->getProperty, _extra=e

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;   filename
;     filename this object represents
;-
pro mgfffilename__define
  compile_opt strictarr

  define = { MGffFilename, filename: '' }
end




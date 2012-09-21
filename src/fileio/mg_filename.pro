; docformat = 'rst'

;+
; Compose and/or decompose a filename.
;
; :Examples:
;    Try the main-level example program at the end of this file::
; 
;       IDL> .run mg_filename
;
;    It should do::
;
;       IDL> f = mg_filename('a.dat', subdir=['b', 'c'], $
;       IDL>                 basename=basename, extension=extension, $
;       IDL>                 dirname=dirname, directories=directories)
;       IDL>                 
;       IDL> print, f, format='(%"Filename:  %s")'
;       Filename:  b/c/a.dat
;       IDL> 
;       IDL> print, basename, format='(%"Basename:  %s")'
;       Basename:  a.dat
;       IDL> print, extension, format='(%"Extension: %s")'
;       Extension: dat
;       IDL> 
;       IDL> print, dirname, format='(%"Directory: %s")'
;       Directory: b/c/
;       IDL> print, strjoin(directories, ', '), format='(%"Directories: %s")'
;       Directories: b, c
;
; :Params:
;    filename : in, optional, type=string
;       filename/basename
;
; :Keywords:
;    object : out, optional, type=object
;       object reference of the underlying `MGffFilename` object; this object
;       will be destroyed if it is not requested using this keyword
;    _ref_extra : in, out, optional, type=keywords
;       keywords to `MGffFilename::init`
;-
function mg_filename, filename, object=object, _ref_extra=e
  compile_opt strictarr
  
  object = obj_new('MGffFilename', filename, _extra=e)
  f = object->toString()
  if (~arg_present(object)) then obj_destroy, object
  return, f
end


; main-level example program

f = mg_filename('a.dat', subdir=['b', 'c'], $
                basename=basename, extension=extension, $
                dirname=dirname, directories=directories)
                
print, f, format='(%"Filename:  %s")'

print, basename, format='(%"Basename:  %s")'
print, extension, format='(%"Extension: %s")'

print, dirname, format='(%"Directory: %s")'
print, strjoin(directories, ', '), format='(%"Directories: %s")'

print, mg_filename('link-%d.html', /clock_basename, /tmp), $
       format='(%"Temporary file with time/date:\n  %s")'

end
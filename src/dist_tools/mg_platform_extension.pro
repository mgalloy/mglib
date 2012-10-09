; docformat = 'rst'

;+
; Returns the platform extension used by the `PLATFORM_EXTENSION` keyword to
; `MAKE_DLL`.
;
; :Examples:
;    For example, on Mac OS X, this should look like::
;
;       IDL> print, mg_platform_extension()
;       darwin.x86_64
;       IDL> print, mg_platform_extension(/extension)
;       darwin.x86_64.so
;
; :Returns:
;    string
;
; :Keywords:
;    extension : in, optional, type=boolean
;       append appropriate shared object extension to return value
;-
function mg_platform_extension, extension=extension
  compile_opt strictarr

  ext = !version.os_family eq 'unix' ? '.so' : '.dll'
  platform = strmid(expand_path('<IDL_BIN_DIRNAME>'), 4)   ; remove "bin."
  return, platform + (keyword_set(extension) ? ext : '')
end


; main-level example program

print, mg_platform_extension(), format='(%"Platform extension: %s")'

end

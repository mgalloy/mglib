; docformat = 'rst'

;+
; Return a singular or plural form of a word based on a value.
;
; :Examples:
;   For example::
;
;     IDL> n = 5
;     IDL> print, n, mg_plural(n, 'file'), format='%d %s'
;     5 files
;     IDL> n = 1
;     IDL> print, n, mg_plural(n, 'file'), format='%d %s'
;     1 file
;
; :Returns:
;   string
;
; :Params:
;   value : in, required, type=integer
;     value to check
;   singular : in, required, type=string
;     string to return if value is 1
;   plural : in, optional, type=string
;     string to return if value is not 1, if not present, the default is the
;     singular value with 's' appended
;-
function mg_plural, value, singular, plural
  compile_opt strictarr

  return, value eq 1 ? singular : mg_default(plural, singular + 's')
end


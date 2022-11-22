; docformat = 'rst'

;+
; Return a singular or plural form of a word based on a value.
;
; :Examples:
;   For example::
;
;     IDL> print, mg_plural(5, 'file')
;     5 files
;     IDL> print, mg_plural(1, 'file')
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
;
; :Keywords:
;   format : in, optional, type=string, default="%d"
;     C-style format code for `value`
;-
function mg_plural, value, singular, plural, format=format
  compile_opt strictarr

  label = value eq 1 ? singular : mg_default(plural, singular + 's')
  fmt = mg_format(mg_default(format, '%d') + ' %s')
  return, string(value, label, format=fmt)
end

; docformat = 'rst'

;+
; Return a singular or plural form of a word based on a value.
;
; :Returns:
;   string
;
; :Params:
;   value : in, required, type=integer
;     value to check
;   singular : in, required, type=string
;     string to return if value is 1
;   plural : in, required, type=string
;     string to return if value is not 1
;-
function mg_plural, value, singular, plural
  compile_opt strictarr

  return, value eq 1 ? singular : plural
end


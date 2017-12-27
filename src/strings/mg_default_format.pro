; docformat = 'rst'

;+
; Returns the default format string for the given type.
;
; :Returns:
;   string
;
; :Parmas:
;   type : in, required, type=integer
;     type code as returned by `SIZE`
;-
function mg_default_format, type
  compile_opt strictarr

  case type of
    1: format = '%4d'
    2: format = '%8d'
    3: format = '%12d'
    4: format = '%#13.6g'
    5: format = '%#16.8g'
    6: format = '(%#13.6g,%#13.6g)'
    7: format = '%s'
    8: format = ''
    9: format = '(%#16.8g,%#16.8g)'
   10: format = '%12lu'
   11: format = '%12lu'
   12: format = '%8u'
   13: format = '%12u'
   14: format = '%22lld'
   15: format = '%22llu'
  endcase

  return, format
end
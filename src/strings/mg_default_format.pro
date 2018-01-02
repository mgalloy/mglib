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
;
; :Keywords:
;   width : in, optional, type=boolean
;     set to indicate to return the width of the format code instead of the
;     format code itself
;-
function mg_default_format, type, width=width
  compile_opt strictarr

  case type of
    1: format = keyword_set(width) ? 4L : '%4d'
    2: format = keyword_set(width) ? 8L : '%8d'
    3: format = keyword_set(width) ? 12L : '%12d'
    4: format = keyword_set(width) ? 13L : '%13.6g'
    5: format = keyword_set(width) ? 16L : '%16.8g'
    6: format = keyword_set(width) ? 27L : '(%13.6g,%13.6g)'
    7: format = keyword_set(width) ? 12L : '%s'
    8: format = keyword_set(width) ? 0L : ''
    9: format = keyword_set(width) ? 33L : '(%16.8g,%16.8g)'
   10: format = keyword_set(width) ? 12L : '%12lu'
   11: format = keyword_set(width) ? 12L : '%12lu'
   12: format = keyword_set(width) ? 8L : '%8u'
   13: format = keyword_set(width) ? 12L : '%12u'
   14: format = keyword_set(width) ? 22L : '%22lld'
   15: format = keyword_set(width) ? 22L : '%22llu'
  endcase

  return, format
end
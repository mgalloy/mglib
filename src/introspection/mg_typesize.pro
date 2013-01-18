; docformat = 'rst'

;+
; Returns the size in bytes of a variable of the given type code. Types which
; don't have a fixed size like strings, pointers, and objects return `-1L`.
;
; :Returns:
;    long
;
; :Params:
;    type_code : in, required, type=integer
;       type code 0-15
;-
function mg_typesize, type_code
  compile_opt strictarr
  on_error, 2

  undefined = 0B

  case type_code of
    0: return, 0L
    1: return, 1L
    2: return, 2L
    3: return, 4L
    4: return, 4L
    5: return, 8L
    6: return, 8L
    7: return, -1L
    8: return, -1L
    9: return, 16L
    10: return, -1L
    11: return, -1L
    12: return, 2L
    13: return, 4L
    14: return, 8L
    15: return, 8L
    else: message, 'invalid type code'
  endcase
end

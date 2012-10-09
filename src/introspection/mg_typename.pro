; docformat = 'rst'

;+
; Returns a nice string name for the given type code.
;
; :Returns:
;    string
;
; :Params:
;    code : in, required, type=int
;       type code as given by the `SIZE` function
;-
function mg_typename, code
  compile_opt strictarr

  case code of
    0 : return, 'undefined'
    1 : return, 'byte'
    2 : return, 'integer'
    3 : return, 'long'
    4 : return, 'float'
    5 : return, 'double'
    6 : return, 'complex'
    7 : return, 'string'
    8 : return, 'structure'
    9 : return, 'double complex'
    10 : return, 'pointer'
    11 : return, 'object'
    12 : return, 'unsigned integer'
    13 : return, 'unsigned long'
    14 : return, '64-bit integer'
    15 : return, 'unsigned 64-bit integer'
  endcase
end

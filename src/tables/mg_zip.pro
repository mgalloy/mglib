; docformat = 'rst'

;+
; Create an array of structures from arrays of all the values of each one of
; the fields of the structure.
;
; :Returns:
;   array of structures
;
; :Params:
;   x1, x2, x3, x4, x5, x6, x7, x8, x9 : in, optional, type=array
;     array of values for the n-th field of the structures
;-
function mg_zip, x1, x2, x3, x4, x5, x6, x7, x8, x9
  compile_opt strictarr

  case n_params() of
    0: return, !null
    1: s = {x1: x1}
    2: s = {x1: x1, x2: x2}
    3: s = {x1: x1, x2: x2, x3: x3}
    4: s = {x1: x1, x2: x2, x3: x3, x4: x4}
    5: s = {x1: x1, x2: x2, x3: x3, x4: x4, x5: x5}
    6: s = {x1: x1, x2: x2, x3: x3, x4: x4, x5: x5, x6: x6}
    7: s = {x1: x1, x2: x2, x3: x3, x4: x4, x5: x5, x6: x6, x7: x7}
    8: s = {x1: x1, x2: x2, x3: x3, x4: x4, x5: x5, x6: x6, x7: x7, x8: x8}
    9: s = {x1: x1, x2: x2, x3: x3, x4: x4, x5: x5, x6: x6, x7: x7, x8: x8, x9: x9}
  endcase

  return, mg_convert_structarr(s)
end

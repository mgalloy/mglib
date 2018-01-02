; docformat = 'rst

;+
; Given two type codes, return a type code of a variable that can contain the
; range of values of both type codes.
;
; :Returns:
;    long
;
; :Params:
;    type1 : in, required, type=long
;       type code of the first variable
;    type2 : in, required, type=long
;       type code of the second variable
;-
function mg_promote_type, type1, type2
  compile_opt strictarr
  
  types = [[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1], $ ; undefined
           [-1,  1,  2,  3,  4,  5,  6, -1, -1,  9, -1, -1, 12, 13, 14, 15], $ ; byte
           [-1,  2,  2,  3,  4,  5,  6, -1, -1,  9, -1, -1,  3, 14, 14,  4], $ ; int
           [-1,  3,  3,  3,  4,  5,  6, -1, -1,  9, -1, -1,  3, 14, 14,  4], $ ; long
           [-1,  4,  4,  4,  4,  5,  6, -1, -1,  9, -1, -1,  4,  4,  4,  4], $ ; float
           [-1,  5,  5,  5,  5,  5,  9, -1, -1,  9, -1, -1,  5,  5,  5,  5], $ ; double
           [-1,  6,  6,  6,  6,  9,  6, -1, -1,  9, -1, -1,  6,  6,  6,  6], $ ; complex
           [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1], $ ; string
           [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1], $ ; structure
           [-1,  9,  9,  9,  9,  9,  9, -1, -1,  9, -1, -1,  9,  9,  9,  9], $ ; dcomplex
           [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1], $ ; pointer
           [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1], $ ; object
           [-1, 12,  3,  3,  4,  5,  6, -1, -1,  9, -1, -1, 12, 13, 14, 15], $ ; uint
           [-1, 13, 14, 14,  4,  5,  6, -1, -1,  9, -1, -1, 13, 13, 14, 15], $ ; ulong
           [-1, 14, 14, 14,  4,  5,  6, -1, -1,  9, -1, -1, 14, 14, 14,  4], $ ; long64
           [-1, 15,  4,  4,  4,  5,  6, -1, -1,  9, -1, -1, 15, 15,  4, 15]]   ; ulong64

  return, types[type1, type2]
end
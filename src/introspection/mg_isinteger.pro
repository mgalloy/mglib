; docformat = 'rst'

;+
; Determines if the argument is an integer type.
;
; :Returns:
;    1 if the argument is an integer type, 0 otherwise
;
; :Params:
;    arg : in, required, type=any
;       arg to test
;-
function mg_isinteger, arg
  compile_opt strictarr
  
  type = size(arg, /type)
  return, total(type eq [1, 2, 3, 12, 13, 14, 15], /preserve_type)
end
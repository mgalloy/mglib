; docformat = 'rst'

;+
; Determines if the argument is an integer type.
;
; :Returns:
;   1 if the argument is an integer type, 0 otherwise
;
; :Params:
;   arg : in, required, type=any
;     arg to test
;
; :Keywords:
;   type : in, optional, type=boolean
;     if set, interpret `arg` as a type code instead of a variable
;-
function mg_isinteger, arg, type=type
  compile_opt strictarr

  type = keyword_set(type) ? arg : size(arg, /type)
  return, total(type eq [1, 2, 3, 12, 13, 14, 15], /preserve_type)
end

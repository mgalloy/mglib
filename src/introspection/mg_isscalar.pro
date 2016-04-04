; docformat = 'rst'

;+
; Determines if the argument is a scalar.
;
; NOTE: this routine determines if the argument is really a scalar, even if it
; is an object which inherits from `IDL_Object` defines `_overloadSize`.
;
; :Returns:
;   1 if the argument is a scalar, 0 otherwise
;
; :Params:
;   arg : in, required, type=any
;     arg to test
;-
function mg_isscalar, arg
  compile_opt strictarr

  return, isa(size(arg, /type) eq 11 ? obj_valid(value) : value, /scalar)
end


; main-level example
lst = list(1, 2, 3)
print, mg_isscalar(lst)
obj_destroy, lst

print, mg_isscalar(5)
print, mg_isscalar([5])

end

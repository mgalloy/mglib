; docformat = 'rst'

;+
; In IDL 8.0, the number of elements of an object can be overloaded with the
; `_overloadSize` method for objects which inherit from `IDL_Object`. It is
; sometimes useful to know how many array elements are present, not the 
; overloaded value.
; 
; :Returns:
;    long
;
; :Params:
;    var : in, optional, type=any
;       variable to find number of elements of
;
; :Keywords:
;    no_operatoroverload : in, optional, type=boolean
;       set to find the number of array elements in var, not the operator 
;       overloaded value
;-
function mg_n_elements, var, no_operatoroverload=noOperatoroverload
  compile_opt strictarr
  
  if (~keyword_set(noOperatoroverload) || size(var, /type) ne 11) then begin
    return, n_elements(var)
  endif
  
  return, n_elements(obj_valid(var))
end

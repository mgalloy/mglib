; docformat = 'rst'

;+
; Wrapper for `CALL_FUNCTION` which accepts an `IDL_Object` that implements
; `_overloadFunction` as well a string function name.
;
; :Returns:
;   the same as `f` returns
;
; :Params:
;   f : in, required, type=IDL_Object or string
;     function to evaluate, either an object of type `IDL_Object` which
;     implements `_overloadFunction` or a string name of a function
;   x1, x2, x3, x4, x5, x6, x7, x8, x9, x10 : in, optional, type=any
;     arguments of `f`
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     keywords of `f`
;-
function mg_call_function, f, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, _extra=e
  compile_opt strictarr

  if (obj_isa(f, 'IDL_Object')) then begin
    if (n_elements(e) eq 0L) then begin
      case n_params() of
         1: return, f()
         2: return, f(x1)
         3: return, f(x1, x2)
         4: return, f(x1, x2, x3)
         5: return, f(x1, x2, x3, x4)
         6: return, f(x1, x2, x3, x4, x5)
         7: return, f(x1, x2, x3, x4, x5, x6)
         8: return, f(x1, x2, x3, x4, x5, x6, x7)
         9: return, f(x1, x2, x3, x4, x5, x6, x7, x8)
        10: return, f(x1, x2, x3, x4, x5, x6, x7, x8, x9)
        11: return, f(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10)
      endcase
    endif else begin
      case n_params() of
         1: return, f(_extra=e)
         2: return, f(x1, _extra=e)
         3: return, f(x1, x2, _extra=e)
         4: return, f(x1, x2, x3, _extra=e)
         5: return, f(x1, x2, x3, x4, _extra=e)
         6: return, f(x1, x2, x3, x4, x5, _extra=e)
         7: return, f(x1, x2, x3, x4, x5, x6, _extra=e)
         8: return, f(x1, x2, x3, x4, x5, x6, x7, _extra=e)
         9: return, f(x1, x2, x3, x4, x5, x6, x7, x8, _extra=e)
        10: return, f(x1, x2, x3, x4, x5, x6, x7, x8, x9, _extra=e)
        11: return, f(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, _extra=e)
      endcase
    endelse
  endif else begin
    if (n_elements(e) eq 0L) then begin
      case n_params() of
         1: return, call_function(f)
         2: return, call_function(f, x1)
         3: return, call_function(f, x1, x2)
         4: return, call_function(f, x1, x2, x3)
         5: return, call_function(f, x1, x2, x3, x4)
         6: return, call_function(f, x1, x2, x3, x4, x5)
         7: return, call_function(f, x1, x2, x3, x4, x5, x6)
         8: return, call_function(f, x1, x2, x3, x4, x5, x6, x7)
         9: return, call_function(f, x1, x2, x3, x4, x5, x6, x7, x8)
        10: return, call_function(f, x1, x2, x3, x4, x5, x6, x7, x8, x9)
        11: return, call_function(f, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10)
      endcase
    endif else begin
      case n_params() of
         1: return, call_function(f, _extra=e)
         2: return, call_function(f, x1, _extra=e)
         3: return, call_function(f, x1, x2, _extra=e)
         4: return, call_function(f, x1, x2, x3, _extra=e)
         5: return, call_function(f, x1, x2, x3, x4, _extra=e)
         6: return, call_function(f, x1, x2, x3, x4, x5, _extra=e)
         7: return, call_function(f, x1, x2, x3, x4, x5, x6, _extra=e)
         8: return, call_function(f, x1, x2, x3, x4, x5, x6, x7, _extra=e)
         9: return, call_function(f, x1, x2, x3, x4, x5, x6, x7, x8, _extra=e)
        10: return, call_function(f, x1, x2, x3, x4, x5, x6, x7, x8, x9, _extra=e)
        11: return, call_function(f, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, _extra=e)
      endcase
    endelse
  endelse
end

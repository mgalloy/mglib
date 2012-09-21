; docformat = 'rst'

;+
; Returns maximum of an array or object which supports FOREACH loops.
;
; :Returns:
;    any
;
; :Params:
;    iterable : in, required, type=array/object
;       array or object which supports FOREACH loops
;    max_subscript : out, optional, type=any
;       array index or key type of object corresponding to the maximum value
;       of `iterable`
;
; :Keywords:
;    key_method : in, optional, type=string
;       name of method to call on the items of `iterable` to determine their 
;       value; this method should be a function with no arguments required and 
;       returning a type which supports comparing with GT and LT
;    key_function : in, optional, type=string
;       name of function to determine the value of the items of `iterable`; 
;       this function should accept one positional parameter (the item of
;       `iterable`) and return a type which supports comparing with GT and LT
;    absolute : in, optional, type=boolean
;       set to use the absolute value of the values in `iterable` to compare
;       for the minimum/maximum value, though the return value will be the
;       original value in `iterable`
;    dimension : in, optional, type=long
;       dimension over which to find the minimum values of an array when 
;       `iterable` is an array and `KEY_FUNCTION` is not used; otherwise it is
;       ignored
;    min : out, optional, type=any
;       minimum value
;    nan : in, optional, type=boolean
;       set to ignore NaN values in arrays; not used if `iterable` is an 
;       object or if `KEY_FUNCTION` is present
;    subscript_min : out, optional, type=any
;       array index or key type of object corresponding to the minimum value
;       of `iterable`
;-
function mg_max, iterable, max_subscript, $
                 key_method=key_method, key_function=key_function, $
                 absolute=absolute, dimension=dimension, min=min_value, nan=nan, $
                 subscript_min=min_subscript
  compile_opt strictarr
  
  ; pass along normal case to MAX routine
  if (size(iterable, /type) ne 11 && n_elements(key_function) eq 0L) then begin
    return, max(iterable, max_subscript, $
                absolute=absolute, dimension=dimension, min=min, nan=nan, $
                subscript_min=min_subscript)
  endif
  
  ; handle objects which support FOREACH
  if (n_elements(key_function) eq 0L && n_elements(key_method) eq 0L) then begin
    initial = 1B
    
    foreach el, iterable, key do begin
      _value = keyword_set(absolute) ? abs(el) : el
      
      if (initial) then begin
        initial = 0B
        
        max_value = el
        max_value_cmp = el
        max_subscript = key
        
        min_value = el
        min_value_cmp = _value
        min_subscript = key
      endif else begin
        if (_value gt max_value_cmp) then begin
          max_value = el
          max_value_cmp = _value
          max_subscript = key
        endif
        
        if (_value lt min_value_cmp) then begin
          min_value = el
          min_value_cmp = _value
          min_subscript = key
        endif
      endelse
    endforeach
    
    return, max_value
  endif
  
  if (n_elements(key_function) ne 0L) then begin
    initial = 1B
    
    foreach el, iterable, key do begin
      _value = call_function(key_function, el)
      _value_cmp = keyword_set(absolute) ? abs(_value) : _value
      
      if (initial) then begin
        initial = 0B
        
        max_value = _value
        max_value_cmp = _value_cmp
        max_subscript = key
        
        min_value = _value
        min_value_cmp = _value_cmp
        min_subscript = key
      endif else begin                
        if (_value gt max_value_cmp) then begin
          max_value = _value
          max_value_cmp = _value_cmp
          max_subscript = key
        endif
        
        if (_value lt min_value_cmp) then begin
          min_value = _value
          min_value_cmp = _value_cmp
          min_subscript = key
        endif
      endelse
    endforeach
    
    return, max_value
  endif
  
  if (n_elements(key_method) ne 0L) then begin
    initial = 1B
    
    foreach el, iterable, key do begin
      _value = call_method(key_method, el)
      _value = keyword_set(absolute) ? abs(_value) : _value

      if (initial) then begin
        initial = 0B
        
        max_value = _value
        max_subscript = key
        
        min_value = _value
        min_subscript = key
      endif else begin
        if (_value gt max_value) then begin
          max_value = _value
          max_subscript = key
        endif
        
        if (_value lt min_value) then begin
          min_value = _value
          min_subscript = key
        endif
      endelse
    endforeach
    
    return, max_value
  endif    
end

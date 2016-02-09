; docformat = 'rst'

;+
; Create an iterator with a `next` method. An iterator can iterate over either
; an array of an object of class `IDL_Object` which implements
; `_overloadForeach`. 
;
; An iterator for a standard array can be created and responds to `mg_next`::
;
;   x = findgen(10)
;   i = mg_iter(x)
;   while (mg_next(i, index=index, value=value)) do begin
;     print, index, value, format='(%"x[%d] = %f")'
;   endwhile
;
; Iterators for objects of class `IDL_Object` which implement `_overloadForeach`
; can also be created and respond to `mg_next`::
;
;   x = list(x, /extract)
;   i = mg_iter(x)
;   while (mg_next(i, index=index, value=value)) do begin
;     print, index, value, format='(%"x[%d] = %f")'
;   endwhile
;
;   n = 26
;   letters = string(reform(bindgen(n) + (byte('a'))[0], 1, n))
;   indices = indgen(n)
;   h = hash(letters, indices, /extract)
;   i = mg_iter(h)
;   while (mg_next(i, index=index, value=value)) do begin
;     print, index, value, format='(%"h[''%s''] = %d")'
;   endwhile
;
; :Properties:
;   cycle : type=boolean
;     set to cycle through iterator over and over
;-


;+
; Advance the iterator.
;
; :Returns:
;   1 if more elements, 0 if done
;
; :Keywords:
;   value : out, optional, type=any
;     set to a named varaible to retrieve the value for this iteration
;   index : out, optional, type=any
;     set to a named varaible to retrieve the index for this iteration
;-
function mg_iter::next, value=value, index=index
  compile_opt strictarr

  is_object = size(*self.iterable, /type) eq 11L
  is_initialized = n_elements(*self.index) gt 0L

  if (is_object) then begin
    if (is_initialized) then _index = *self.index
    more_elements = (*self.iterable)->_overloadForeach(value, _index)
    *self.index = _index
    index = _index
  endif else begin
    if (is_initialized) then begin
      index = *self.index + 1L
    endif else begin
      index = 0L
    endelse

    more_elements = index lt n_elements(*self.iterable)
    if (more_elements) then value = (*self.iterable)[index]
    *self.index = index
  endelse

  if (~more_elements && self.cycle) then begin
    !null = temporary(*self.index)
    return, self->next(value=value, index=index)
  endif else return, more_elements
end


;= property access

;+
; Set properties.
;-
pro mg_iter::setProperty, cycle=cycle
  compile_opt strictarr

  if (n_elements(cycle) gt 0L) then self.cycle = cycle
end


;= lifecycle methods

;+
; Free resources.
;-
pro mg_iter::cleanup
  compile_opt strictarr

  ptr_free, self.index, self.iterable
end


;+
; Create an `MG_Iter` object.
;
; :Returns:
;   1 if successful, 0 for failure
;
; :Params:
;   iterable : in, required, type=object/array
;     either an array or an object of class `IDL_Object` which implements
;     `_overloadForeach`
;-
function mg_iter::init, iterable, cycle=cycle
  compile_opt strictarr

  self.iterable = ptr_new(iterable)
  self.index = ptr_new(/allocate_heap)

  self->setProperty, cycle=cycle

  return, 1
end


;+
; Define `MG_Iter` class.
;-
pro mg_iter__define
  compile_opt strictarr

  !null = {mg_iter, inherits IDL_Object, $
           iterable: ptr_new(), $
           index: ptr_new(), $
           cycle: 0B $
          }
end

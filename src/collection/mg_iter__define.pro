; docformat = 'rst'

;+
; Create an iterator with a `next` method. An iterator can iterate over either
; an array of an object of class `IDL_Object` which implements
; `_overloadForeach`. 
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
    return, more_elements
  endif else begin
    if (is_initialized) then begin
      index = *self.index + 1L
    endif else begin
      index = 0L
    endelse

    value = (*self.iterable)[index]
    *self.index = index
    more_elements = (index + 1L) lt n_elements(*self.iterable)
    return, more_elements
  endelse
end


;= lifecycle methods

pro mg_iter::cleanup
  compile_opt strictarr

  ptr_free, self.index, self.iterable
end


function mg_iter::init, iterable
  compile_opt strictarr

  self.iterable = ptr_new(iterable)
  self.index = ptr_new(/allocate_heap)

  return, 1
end


pro mg_iter__define
  compile_opt strictarr

  !null = {mg_iter, inherits IDL_Object, $
           iterable: ptr_new(), $
           index: ptr_new() $
          }
end

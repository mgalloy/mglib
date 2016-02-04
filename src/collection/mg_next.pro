; docformat = 'rst'

;+
; Advance an iterator.
;
; :Returns:
;   1 if more elements, 0 if no more elements
;
; :Params:
;   iterator : in, required, type=object
;     object with a `next` method, such as `MG_ITER` objects::
;
;       has_more_elements = class::next, value=value, index=index
;
; :Keywords:
;   index : out, optional, type=any
;     set to a named variable to retrieve the current index of the iterator
;   value : out, optional, type=any
;     set to a named variable to retrieve the current value of the iterator
;-
function mg_next, iterator, index=index, value=value
  compile_opt strictarr

  return, iterator->next(value=value, index=index)
end


; main-level example program

print, 'Iterating over an array...'
x = findgen(10)
i = mg_iter(x)
while (mg_next(i, index=index, value=value)) do begin
  print, index, value, format='(%"x[%d] = %f")'
endwhile

print, 'Iterating over a list...'
x = list(x, /extract)
i = mg_iter(x)
while (mg_next(i, index=index, value=value)) do begin
  print, index, value, format='(%"x[%d] = %f")'
endwhile

print, 'Iterating over a hash...'
n = 26
letters = string(reform(bindgen(n) + (byte('a'))[0], 1, n))
indices = indgen(n)
h = hash(letters, indices, /extract)
i = mg_iter(h)
while (mg_next(i, index=index, value=value)) do begin
  print, index, value, format='(%"h[''%s''] = %d")'
endwhile

end

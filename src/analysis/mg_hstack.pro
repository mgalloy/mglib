; docformat = 'rst'

;+
; Horizontally stack two arrays. `x` and `y` must be of the same size except in
; the first dimension. If one of `x` or `y` has one less dimension than the
; other, a new dimension of size 1 will be inserted in dimension 1.
;
; This equivalent to::
;
;   mg_concatenate(x, y, dimension=1)
;
; :Returns:
;   array of type that can handle both `x` and `y`
;
; :Params:
;   x : in, required, type=array
;     first input array
;   y : in, required, type=array
;     second input array
;-
function mg_hstack, array1, array2
  compile_opt strictarr

  return, mg_concatenate(array1, array2, dimension=1)
end


; main-level example program

x = findgen(3, 5)
y = findgen(2, 5)

xy = mg_hstack(x, y)  ; should be a 5 x 5 array
help, xy
print, xy

print

print, mg_hstack(findgen(5), y)

end

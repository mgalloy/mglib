; docformat = 'rst'

;+
; Vertically stack two arrays. `x` and `y` must be of the same size except in
; the second dimension. If one of `x` or `y` has one less dimension than the
; other, a new dimension of size 1 will be inserted in dimension 2.
;
; This equivalent to::
;
;   mg_concatenate(x, y, dimension=2)
;
; :Returns:
;   array of type that can handle both `x` and `y`
;
; :Params:
;   x : in, required, type=any
;     first input array
;   y : in, required, type=any
;     second input array
;-
function mg_vstack, x, y
  compile_opt strictarr

  return, mg_concatenate(x, y, dimension=2)
end


; main-level example program

x = findgen(3, 4)
y = findgen(3, 3)

xy = mg_vstack(x, y)  ; should be a 5 x 5 array
help, xy
print, xy

end
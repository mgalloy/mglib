; docformat = 'rst'

;+
; Computes the arc length of a path.
;
; :Returns:
;    float/double
;
; :Params:
;    x : in, required, type=fltarr(n)
;       x-coords of path
;    y : in, required, type=fltarr(n)
;       y-coords of path
;-
function mg_arclength, x, y
  compile_opt strictarr
  
  _x = [shift(x, -1), 0.]
  _y = [shift(y, -1), 0.]
  d = sqrt((x - _x) * (x - _x) + (y - _y) * (y - _y))
  
  return, total(d[0:n_elements(d) - 2L])
end


; main-level example program

x = [0, 1, 1, 0]
y = [0, 0, 1, 0]

print, mg_arclength(x, y)

end

; docformat = 'rst'

;+
; Rotate an array of points about the origin, or a given center.
;
; :Params:
;   x : in, required, type=fltarr
;     x-coordinates of points
;   y : in, required, type=fltarr
;     y-coordinates of points
;   theta : in, required, type=float
;     angle to rotate points counter-clockwise by, in degrees
;
; :Keywords:
;   new_x : out, optional, type=fltarr
;     x-coordinates of rotated points
;   new_y : out, optional, type=fltarr
;     y-coordinates of rotated points
;   center : in, optional, type=fltarr(2), default="[0, 0]"
;     center to rotate around
;-
pro mg_rotate_points, x, y, theta, new_x=new_x, new_y=new_y, center=center
  compile_opt strictarr

  t = theta * !dtor

  ; translate points to origin, if rotating about a point besides the origin
  if (n_elements(center) eq 0L) then begin
    _x = x
    _y = y
  endif else begin
    _x = x - center[0]
    _y = y - center[1]
  endelse

  new_x = _x * cos(t) - _y * sin(t)
  new_y = _x * sin(t) + _y * cos(t)

  ; translate the points back to the original center, if translated to origin
  if (n_elements(center) gt 0L) then begin
    new_x += center[0]
    new_y += center[1]
  endif
end


; main-level example

x = [0.0, 0.0, 100.0, 100.0]
y = [0.0, 100.0, 100.0, 0.0]
center = [50.0, 50.0]
mg_rotate_points, x, y, 45.0, new_x=new_x, new_y=new_y, center=center
print, new_x, new_y

end

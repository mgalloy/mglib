; docformat = 'rst'


;+
; Create the polyline atoms.
;
; :Private:
;
; :Todo:
;   implement
;
; :Params:
;   x : in, required, type=fltarr
;     x-coordinates of lines
;   y : in, required, type=fltarr
;     y-coordinates of lines
;-
pro mggrpolyline2d::_create, x, y
  compile_opt strictarr

  densityDims = [400, 400]

  maxx = max(x, min=minx)
  maxy = max(y, min=miny)



end


;= lifecycle methods

;+
; Create polyline object.
;
; :Returns:
;   1 for success, 0 otherwise
;
; :Params:
;   x : in, required, type=fltarr
;     x-coordinates of lines
;   y : in, required, type=fltarr
;     y-coordinates of lines
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     keywords to `IDLgrSurface::init`
;-
function mggrpolyline2d::init, x, y, _extra=e
  compile_opt strictarr

  if (~self->IDLgrSurface::init(_extra=e)) then return, 0

  self->_create, x, y

  return, 1
end


;+
; Define instance variables.
;-
pro mggrpolyline2d__define
  compile_opt strictarr

  define = { MGgrPolyline2d, inherits IDLgrSurface }
end


; main-level example program

t = findgen(360) * !dtor
x = cos(t)
y = sin(t)

view = obj_new('IDLgrView')
model = obj_new('IDLgrModel')
view->add, model
p = obj_new('IDLgrPolyline', x, y)
model->add, p

win = obj_new('IDLgrWindow', dimensions=[400, 400], graphics_tree=view)
win->draw

end

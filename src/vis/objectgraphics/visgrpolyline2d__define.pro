; docformat = 'rst'

pro visgrpolyline2d::_create, x, y
  compile_opt strictarr
  
  densityDims = [400, 400]
  
  maxx = max(x, min=minx)
  maxy = max(y, min=miny)
  

  
end


function visgrpolyline2d::init, x, y, _extra=e
  compile_opt strictarr

  if (~self->IDLgrSurface::init(_extra=e)) then return, 0
  
  self->_create, x, y
  
  return, 1
end


pro visgrpolyline2d__define
  compile_opt strictarr
  
  define = { VISgrPolyline2d, inherits IDLgrSurface }
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

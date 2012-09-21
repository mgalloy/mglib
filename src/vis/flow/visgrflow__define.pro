; docformat = 'rst'

;+
; :Examples:
;    Run the main-level program at the end of this file for an example of the
;    usage::
;
;       IDL> .run visgrflow__define
;
;    This should display:
;
;    .. image:: og-flow.png
;-

;+
; Create a flow display.
;
; :Params:
;    u : in, required, type="fltarr(m, n)"
;       x component at each point of the vector field; must be a 2D array
;    v : in, required, type="fltarr(m, n)"  
;       y component at each point of the vector field; must be a 2D array
;    x : in, optional, type=fltarr(m)
;       x axis values
;    y : in, optional, type=fltarr(n)
;       y axis values
;
; :Keywords:
;    _extra : in, optional, type=keywords
;       keywords to IDLgrPolyline::init or VIS_VEL
;-
function visgrflow::init, u, v, x, y, _extra=e
  compile_opt strictarr
    
  if (~self->IDLgrPolyline::init(_extra=e)) then return, 0

  su = size(u, /structure)
  
  _x = n_elements(x) eq 0L ? findgen(su.dimensions[0]) : x
  _y = n_elements(y) eq 0L ? findgen(su.dimensions[1]) : y
  xmin = min(_x, max=xmax)
  ymin = min(_y, max=ymax)
    
  vis_vel, u, v, _x, _y, streamlines=s, _extra=e
  
  dims = size(s, /dimensions)
  
  vertices = transpose(reform(s, dims[0] * dims[1], 2))
  vertices[0, *] = (xmax - xmin) * vertices[0, *] + xmin
  vertices[1, *] = (ymax - ymin) * vertices[1, *] + ymin  
  
  polylines = [[lonarr(dims[0]) + 13L], [lindgen(dims[0], 13)]]
  polylines = reform(transpose(polylines), dims[0] * 14L)
  
  self->setProperty, data=vertices, polylines=polylines
  
  return, 1
end


;+
; Define inheritance and instance variables.
;-
pro visgrflow__define
  compile_opt strictarr
  
  define = { VISgrFlow, inherits IDLgrPolyline }
end


; main-level example program

restore, filepath('globalwinds.dat', subdir=['examples','data'])

view = obj_new('IDLgrView')

model = obj_new('IDLgrModel')
view->add, model

flow = obj_new('VISgrFlow', u, v, x, y, /grid, stride=3, color=[50, 150, 50])
model->add, flow

flow->getProperty, xrange=xr, yrange=yr
xc = vis_linear_function(xr, [-0.75, 0.75])
yc = vis_linear_function(yr, [-0.75, 0.75])
flow->setProperty, xcoord_conv=xc, ycoord_conv=yc

xaxis = obj_new('IDLgrAxis', $
                direction=0, location=[min(x), min(y)], $
                range=[-180, 180], /exact, major=5, $
                xcoord_conv=xc, ycoord_conv=yc)
model->add, xaxis

yaxis = obj_new('IDLgrAxis', $
                direction=1, location=[min(x), min(y)], $
                range=[-90, 90], /exact, major=5, $
                xcoord_conv=xc, ycoord_conv=yc)
model->add, yaxis

win = obj_new('IDLgrWindow', graphics_tree=view)
win->draw

end

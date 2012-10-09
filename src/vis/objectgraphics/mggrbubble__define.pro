; docformat = 'rst'

;+
; :Examples:
;    Try the main-level example program at the end of this file::
;
;       IDL> .run mggrbubble__define
;
;    This should produce:
;
;    .. image:: bubbles.png
;
; :Properties:
;    size : type=float
;       sizes of bubble; size of radius unless AREA is set, in which case it
;       is the size of the area of the bubble
;    area : type=boolean
;       set to specify SIZE as areas instead of radii
;    color : type=color
;       color of the interior of the bubbles
;    border_color : type=color
;       color of the bubble border
;    _extra : type=keywords
;       IDLgrPolygon or IDLgrPolyline properties
;    _ref_extra : type=keywords
;       IDLgrPolygon or IDLgrPolyline properties
;-


;+
; Helper routine to calculate the bubble's border.
;
; :Private:
;
; :Keywords:
;    x : out, optional, type=fltarr
;       x-coordinates of bubble border
;    y : out, optional, type=fltarr
;       y-coordinates of bubble border
;-
pro mggrbubble::_calculate, x=_x, y=_y
  compile_opt strictarr

  t = findgen(self.n) / (self.n - 1.) * 360. * !dtor
  r = self.area ? sqrt(self.size / !pi) : self.size

  _x = self.x + r * cos(t)
  _y = self.y + r * sin(t)
end


;+
; Get bubble properties.
;-
pro mggrbubble::getProperty, size=size, area=area, $
                             color=color, border_color=borderColor, $
                             _ref_extra=e
  compile_opt strictarr

  polygon = self->getByName('polygon')
  polyline = self->getByName('polyline')

  if (arg_present(size)) then size = self.size
  if (arg_present(area)) then area = self.area

  if (arg_present(color)) then begin
    self.polygon->getProperty, color=color
  endif

  if (arg_present(borderColor)) then begin
    self.polyline->getProperty, color=borderColor
  endif

  if (n_elements(e) gt 0L) then begin
    polygon->getProperty, _extra=e
    polyline->getProperty, _extra=e
    self->IDLgrModel::getProperty, _extra=e
  endif
end


;+
; Set properties.
;-
pro mggrbubble::setProperty, size=size, area=area, $
                             color=color, border_color=borderColor, $
                             _extra=e
  compile_opt strictarr

  polygon = self->getByName('polygon')
  polyline = self->getByName('polyline')

  if (n_elements(size) gt 0L) then begin
    self.size = size
    self->_calculate, x=_x, y=_y
    data = fltarr(2, self.n)
    data[0, *] = _x
    data[1, *] = _y
    polygon->setProperty, data=data
    polyline->setProperty, data=data
  endif

  if (n_elements(area)) then begin
    self.area = keyword_set(area)
    self->_calculate, x=_x, y=_y
    data = fltarr(2, self.n)
    data[0, *] = _x
    data[1, *] = _y
    polygon->setProperty, data=data
    polyline->setProperty, data=data
  endif

  if (n_elements(color) gt 0L) then self.polygon->setProperty, color=color
  if (n_elements(borderColor) gt 0L) then begin
    self.polyline->setProperty, color=borderColor
  endif

  if (n_elements(e) gt 0L) then begin
    polygon->setProperty, _extra=e
    polyline->setProperty, _extra=e
    self->IDLgrModel::setProperty, _extra=e
  endif
end


;+
; Create a bubble.
;
; :Params:
;    x : in, required, type=float
;       x-coordinate of center of bubble
;    y : in, required, type=float
;       y-coordinate of center of bubble
;    z : in, optional, type=float, default=1.0
;       z-coordinate of center of bubble
;
; :Keywords:
;    size : in, optional, type=float/fltarr
;       sizes of bubble; size of radius unless AREA is set, in which case it
;       is the size of the area of the bubble
;    area : in, optional, type=boolean
;       set to specify SIZE as areas instead of radii
;    color : in, optional, type=color, default=0B
;       color of bubble
;    border_color : in, optional, type=color, default=0B
;       color of bubble edge
;-
function mggrbubble::init, x, y, z, size=size, area=area, $
                           color=color, border_color=borderColor, _extra=e
  compile_opt strictarr

  if (~self->IDLgrModel::init(_extra=e)) then return, 0

  self.size = n_elements(size) eq 0L ? 1.0 : size
  self.area = keyword_set(area)

  _color = n_elements(color) eq 0L ? 0B : color
  _borderColor = n_elements(borderColor) eq 0L ? 0B : borderColor

  self.n = 36

  self.x = x
  self.y = y

  self->_calculate, x=_x, y=_y
  _z = fltarr(self.n) + (n_elements(z) eq 0L ? 1.0 : z)

  polygon = obj_new('IDLgrPolygon', _x, _y, _z, name='polygon', color=color, $
                    depth_offset=1, _extra=e)
  self->add, polygon

  polyline = obj_new('IDLgrPolyline', _x, _y, _z, name='polyline', $
                     color=_borderColor, _extra=e)
  self->add, polyline

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    n
;       number of points in the border of the bubble
;    x
;       x-coordinate of the center of the bubble
;    y
;       y-coordinate of the center of the bubble
;    size
;       size of the bubble
;    area
;       flag indicating whether size is a radius or the area of the bubble
;-
pro mggrbubble__define
  compile_opt strictarr

  define = { MGgrBubble, inherits IDLgrModel, $
             n: 0L, $
             x: 0.0, $
             y: 0.0, $
             size: 0.0, $
             area: 0B $
           }
end


; main-level example program

view = obj_new('IDLgrView', color=[255, 255, 255])

model = obj_new('IDLgrModel')
view->add, model

n = 60
x = 2. * randomu(seed, n) - 1.
y = 2. * randomu(seed, n) - 1.
size = 0.1 * randomu(seed, n)
color = byte(255. * randomu(seed, n, 3))
bubbles = mg_create_bubbles(x, y, size=size, /area, $
                            color=color, border_color=color / 2B, $
                            alpha_channel=0.5)
model->add, bubbles

win = obj_new('IDLgrWindow', dimension=[400, 400], graphics_tree=view)
win->draw, view

end
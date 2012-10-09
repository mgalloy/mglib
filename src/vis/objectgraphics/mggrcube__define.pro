; docformat = 'rst'

;+
; Unit cube polygon (maybe scaled and translated).
;
; :Categories:
;    object graphics
;
; :Examples:
;    See the main-level program at the end of this file::
;
;       IDL> .run mggrcube__define
;
;    This should produce an image of 100 cubes of random size, location,
;    color, style, and shading:
;
;    .. image:: cubes.png
;
; :Properties:
;    scale : type=float/fltarr(3)
;       scale cube either equally or separately in each direction
;    translate : type=fltarr(3)
;       translate the cube to another location
;    _extra : type=keywords
;       properties from IDLgrPolygon
;-


;+
; Compute the new vertices of the cube.
;
; :private:
;
; :Params:
;    x : out, optional, type=fltarr(8)
;       x-coordinates of vertices
;    y : out, optional, type=fltarr(8)
;       y-coordinates of vertices
;    z : out, optional, type=fltarr(8)
;       z-coordinates of vertices
;-
pro mggrcube::_computeVertices, x, y, z
  compile_opt strictarr

  x = self.scale[0] * self.x + self.translate[0]
  y = self.scale[1] * self.y + self.translate[1]
  z = self.scale[2] * self.z + self.translate[2]
end


;+
; Set properties.
;-
pro mggrcube::setProperty, scale=scale, translate=translate, _extra=e
  compile_opt strictarr

  if (n_elements(scale) gt 0L) then self.scale = scale
  if (n_elements(translate) gt 0L) then self.translate = translate

  if (n_elements(scale) gt 0L || n_elements(translate) gt 0L) then begin
    self->_computeVertices, x, y, z
    self->IDLgrPolygon::setProperty, data=transpose([[x], [y], [z]])
  endif

  if (n_elements(e) gt 0L) then self->IDLgrPolygon::setProperty, _extra=e
end


;+
; Get properties.
;-
pro mggrcube::getProperty, scale=scale, translate=translate, _ref_extra=e
  compile_opt strictarr

  if (arg_present(scale)) then scale = self.scale
  if (arg_present(translate)) then translate = self.translate

  if (n_elements(e) gt 0L) then self->IDLgrPolygon::getProperty, _extra=e
end

;+
; Create a cube polygon.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mggrcube::init, scale=scale, translate=translate, _extra=e
  compile_opt strictarr
  on_error, 2

  case n_elements(scale) of
    0: self.scale = [1., 1., 1.]
    1: self.scale = fltarr(3) + scale
    3: self.scale = scale
    else: message, 'incorrect number of elements in SCALE'
  endcase

  case n_elements(translate) of
    0: self.translate = [0., 0., 0.]
    1: self.translate = fltarr(3) + translate
    3: self.translate = translate
    else: message, 'incorrect number of elements in TRANSLATE'
  endcase

  self.x = [0., 1., 1., 0., 0., 1., 1., 0.]
  self.y = [0., 0., 1., 1., 0., 0., 1., 1.]
  self.z = [0., 0., 0., 0., 1., 1., 1., 1.]

  self->_computeVertices, x, y, z

  p = [4, 0, 1, 2, 3, $
       4, 4, 7, 6, 5, $
       4, 5, 6, 2, 1, $
       4, 0, 3, 7, 4, $
       4, 7, 3, 2, 6, $
       4, 0, 4, 5, 1]

  if (~self->idlgrpolygon::init(x, y, z, polygons=p, _extra=e)) then return, 0

  return, 1
end


;+
; Define instance variables.
;-
pro mggrcube__define
  compile_opt strictarr

  define = { MGgrCube, inherits IDLgrPolygon, $
             x: fltarr(8), $
             y: fltarr(8), $
             z: fltarr(8), $
             scale: fltarr(3), $
             translate: fltarr(3) $
           }
end


; example of using this routine

view = obj_new('IDLgrView')

model = obj_new('IDLgrModel')
view->add, model

ncubes = 100
for c = 0L, ncubes - 1L do begin
  cube = obj_new('MGgrCube', $
                 scale=0.1 * randomu(seed, 3), $
                 translate=randomu(seed, 3) - 0.5, $
                 color=255. * randomu(seed, 3), $
                 style=fix(3 * randomu(seed, 1)), $
                 shading=fix(2 * randomu(seed, 1)))
  model->add, cube
endfor

light = obj_new('IDLgrLight', type=2, location=[1, 1, 1])
model->add, light

alight = obj_new('IDLgrLight', type=0, intensity=0.5)
model->add, alight

model->rotate, [1, 0, 0], -90
model->rotate, [0, 1, 0], 30
model->rotate, [1, 0, 0], 45

win = obj_new('IDLgrWindow', dimensions=[400, 400], graphics_tree=view)
win->draw

end
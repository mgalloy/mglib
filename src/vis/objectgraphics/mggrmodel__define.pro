; docformat = 'rst'

;+
; Subclass of `IDLgrModel` with some extra abilities, like rotating around a
; point besides the origin.
;-


;+
; Rotate the model, possibly about a non-origin point.
;
; :Params:
;    axis : in, optional, type=fltarr(3)
;       axis of rotation
;    angle : in, optional, type=float
;       angle to rotate model by
;
; :Keywords:
;    about : in, optional, type=fltarr(3)
;       point to rotate about
;    _extra : in, optional, type=keywords
;       keywords to IDLgrModel::rotate
;-
pro mggrmodel::rotate, axis, angle, about=about, _extra=extra
  compile_opt strictarr

  if (n_elements(about) gt 0L) then self->translate, -about[0], -about[1], -about[2]
  self->idlgrmodel::rotate, axis, angle, _extra=e
  if (n_elements(about) gt 0L) then self->translate, about[0], about[1], about[2]
end


;+
; Define instance variables.
;-
pro mggrmodel__define
  compile_opt strictarr

  define = { MGgrModel, inherits IDLgrModel }
end


; main-level example program

loc = [-0.5, 0., 0.]

earth = read_image(filepath('earth.jpg', subdir=['examples', 'demo', 'demodata']))
earth = mg_image_flip(earth)

image = obj_new('IDLgrImage', earth)

viewgroup = obj_new('IDLgrViewGroup')
viewgroup->add, image

view = obj_new('IDLgrView', color=[0, 0, 0])
viewgroup->add, view

model = obj_new('MGgrModel')
view->add, model

orb = obj_new('Orb', pos=loc, radius=0.25, color=[255, 255, 255], density=1., $
              texture_map=image, /tex_coords)
model->add, orb

light_model = obj_new('IDLgrModel')
view->add, light_model

light = obj_new('IDLgrLight', type=2, location=[-1, 1, 1])
light_model->add, light

win = obj_new('IDLgrWindow', dimensions=[400, 400], graphics_tree=viewgroup)
win->draw, viewgroup

model->rotate, [1, 0, 0], -90
win->draw

nrotations = 3L

for i = 0, 360 * nrotations - 1L do begin
  model->rotate, [0, 1, 0], 1, about=loc
  win->draw
endfor

end

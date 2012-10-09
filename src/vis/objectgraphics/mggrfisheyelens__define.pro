; docformat = 'rst'

pro mggrfisheyelens::update
  compile_opt strictarr
  on_error, 2

  if (self->count() eq 0L) then begin
    model = obj_new('IDLgrModel', name='model')
    self->add, model
    im = obj_new('IDLgrImage', name='image', depth_test_function=2, depth_offset=1)
    model->add, im
  endif else begin
    im = self->getByName('model/image')
  endelse

  self->getProperty, parent=scene
  if (~obj_valid(scene)) then return

  if (~obj_isa(scene, 'IDLgrScene')) then begin
    message, 'parent of fish eye lens must be a scene'
  endif

  d = bytarr(4, 256, 256) + 255B

  circle = shift(dist(256, 256), self.center[0], self.center[1]) lt self.radius
  ind = where(circle, count)
  alpha = bytarr(256, 256)
  alpha[ind] = 255B

  d[3, *, *] = 255B - alpha

  self->setProperty, viewplane_rect=[0, 0, 255, 255]
  im->setProperty, data=d, interleave=0
end


pro mggrfisheyelens::setProperty, center=center, radius=radius, _extra=e
  compile_opt strictarr

  if (n_elements(center) gt 0L) then self.center = center
  if (n_elements(radius) gt 0L) then self.radius = radius

  if (n_elements(e) gt 0L) then self->IDLgrView::setProperty, _extra=e
end


pro mggrfisheyelens::getProperty, center=center, radius=radius, _ref_extra=e
  compile_opt strictarr

  center = self.center
  radius = self.radius

  if (n_elements(e) gt 0L) then self->IDLgrView::getProperty, _extra=e
end


pro mggrfisheyelens::cleanup
  compile_opt strictarr

  self->IDLgrView::cleanup
end


function mggrfisheyelens::init, _extra=e
  compile_opt strictarr

  if (~self->IDLgrView::init(_extra=e)) then return, 0

  self->setProperty, _extra=e
  self->setProperty, /transparent, color=[0B, 0B, 0B]

  self->update

  return, 1
end


pro mggrfisheyelens__define
  compile_opt strictarr

  define = { MGgrFishEyeLens, inherits IDLgrView,$
             center: fltarr(2), $
             radius: 0. $
           }
end


; main-level example program

scene = obj_new('IDLgrScene')

view = obj_new('IDLgrView', viewplane_rect=[0, 0, 256, 256])
scene->add, view

fisheye = obj_new('MGgrFishEyeLens', center=[128, 128], radius=10.)
scene->add, fisheye
fisheye->update

model = obj_new('IDLgrModel')
view->add, model

im = obj_new('IDLgrImage', read_image(file_which('people.jpg')))
model->add, im

win = obj_new('IDLgrWindow', dimensions=[256, 256], graphics_tree=scene)
win->draw

end

; docformat = 'rst'

;+
; Destination class graphics window like `IDLgrWindow` that uses POVRay to
; render the graphics.
;
; :Properties:
;    _ref_extra : type=keywords
;       keywords to `MGgrPOVRay` and `IDLgrWindow`
;    _extra : type=keywords
;       keywords to `MGgrPOVRay` and `IDLgrWindow`
;-

;+
; Draws graphics hierarchy to the window using `MGgrPOVRay`.
;
; :Params:
;    picture : in, optional, type=object
;       `IDLgrScene`, `IDLgrViewGroup`, or `IDLgrView` rooting object graphics
;       hierarchy to draw; required if `GRAPHICS_TREE` property is not set
;-
pro mggrpovraywindow::draw, picture
  compile_opt strictarr

  if (n_elements(picture) gt 0L) then begin
    _picture = picture
  endif else begin
    self->IDLgrWindow::getProperty, graphics_tree=_picture
  endelse

  self.povray->draw, _picture

  self.povray->getProperty, file_prefix=filePrefix
  im = mg_povray(filePrefix)

  image = self.view->getByName('model/image')
  image->setProperty, data=im

  self->IDLgrWindow::draw, self.view
end


;+
; Get properties.
;-
pro mggrpovraywindow::getProperty, _ref_extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then begin
    self->IDLgrWindow::getProperty, _extra=e
    self.povray->getProperty, _extra=e
  endif
end


;+
; Set properties.
;-
pro mggrpovraywindow::setProperty, _extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then begin
    self->IDLgrWindow::setProperty, _extra=e
    self.povray->setProperty, _extra=e
  endif
end


;+
; Free resources.
;-
pro mggrpovraywindow::cleanup
  compile_opt strictarr

  if (~self.keepFiles) then begin
    self.povray->getProperty, file_prefix=filePrefix
    file_delete, file_dirname(filePrefix), /recursive
  endif

  obj_destroy, [self.view, self.povray]

  self->IDLgrWindow::cleanup
end


;+
; Create a `MGgrPOVRayWindow` instance.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mggrpovraywindow::init, file_prefix=filePrefix, $
                                 keep_files=keepFiles, $
                                 _extra=e
  compile_opt strictarr

  if (~self->IDLgrWindow::init(_extra=e)) then return, 0

  self.keepFiles = keyword_set(keepFiles)
  _filePrefix = n_elements(filePrefix) eq 0L $
                  ? filepath('mggrpovray', $
                             subdir=string(systime(/seconds), $
                                           format='(%"mggrpovray-%d")'), $
                             root=filepath('', /tmp)) $
                  : filePrefix
  self.povray = obj_new('MGgrPovray', file_prefix=_filePrefix, _extra=e)
  self.povray->getProperty, dimensions=dimensions

  self.view = obj_new('IDLgrView', viewplane_rect=[0, 0, dimensions])

  model = obj_new('IDLgrModel', name='model')
  self.view->add, model

  image = obj_new('IDLgrImage', name='image')
  model->add, image

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    view
;       object graphics hierarchy rooted at an `IDLgrView`
;    povray
;       `MGgrPOVRay` destination class
;    keepFiles
;       keeps output files if set
;-
pro mggrpovraywindow__define
  compile_opt strictarr

  define = { MGgrPOVRayWindow, inherits IDLgrWindow, $
             view: obj_new(), $
             povray: obj_new(), $
             keepFiles: 0B $
           }
end


; main-level example program

view = obj_new('IDLgrView', name='view', color=[200, 200, 255])

model = obj_new('IDLgrModel', name='model')
view->add, model

cowFilename = filepath('cow10.sav', subdir=['examples', 'data'])
restore, cowFilename
colors = randomu(seed, n_elements(x))
vertcolors = rebin(reform(255 * round(colors), $
                   1, n_elements(x)), 3, n_elements(x))

cow = obj_new('IDLgrPolygon', x, y, z, polygons=polylist, $
              color=[150, 100, 20], shading=1, $
              ;vert_colors=vertcolors, clip_planes=[0, 0, 1, 0], $
              shininess=25.0, ambient=[150, 100, 20], diffuse=[150, 100, 20])
model->add, cow

xmin = min(x, max=xmax)
xrange = xmax - xmin
ymin = min(y, max=ymax)
yrange = ymax - ymin
zmin = min(z, max=zmax)
zrange = zmax - zmin

plane = obj_new('IDLgrPolygon', $
                [xmin, xmin, xmax, xmax] + [-1., -1., 1., 1.] * 5. * xrange, $
                fltarr(4) + ymin, $
                [zmin, zmax, zmax, zmin] + [-1., 1., 1., -1.] * 5. * zrange, $
                color=[25, 100, 50], style=2)
model->add, plane

model->rotate, [0, 1, 0], -45
model->rotate, [1, 0, 0], 30

light = obj_new('IDLgrLight', type=2, location=[0, 5, 5], intensity=2.0)
model->add, light
alight = obj_new('IDLgrLight', type=0, intensity=2.0)
model->add, alight

win = obj_new('MGgrPOVRayWindow', $
              dimensions=[640, 480], $
              title='Object graphics Cow')
win->setProperty, graphics_tree=view
win->draw

end

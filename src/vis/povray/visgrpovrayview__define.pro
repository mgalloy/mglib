; docformat = 'rst'

;+
; Controls top-level properties of the POV-Ray scene like focal blur.
;
; :Categories:
;    object graphics
;
; :Examples:
;    Focal blur can be set up by setting the APERTURE and BLUR_SAMPLES 
;    keywords when creating the view::
;    
;       view = obj_new('VISgrPOVRayView', name='view', color=[200, 200, 255], $
;                      aperture=0.4, blur_samples=20L) 
;               
;    The FOCAL_POINT can be set later when the coordinate transformations are
;    known since the coordinates of the FOCAL_POINT are in view coordinates,
;    not data coordinates:: 
;               
;       view->setProperty, focal_point=vis_transformpoint([0.52, 0.317, 0.0], cow)
;                
;    See the example attached to the end of this file as a main-level program 
;    (only available if you have the source code version of this routine)::
;       
;       IDL> .run visgrpovrayview__define
;        
;    This should produce output with a focal blur (focus is on the cow's 
;    head):
;    
;    .. image:: view.png
;    
; :Properties:
;    focal_point
;       point which the camera focuses in view coordinates (not data 
;       coordinates)
;    aperture
;       aperature of camera (small aperature value gives a larger depth of 
;       field)
;    blur_samples
;      number of rays used to sample each pixel in POV-Ray
;-

;+
; Get properties.
;-
pro visgrpovrayview::getProperty, focal_point=focalPoint, $
                                  aperture=aperture, $
                                  blur_samples=blurSamples, $
                                  _ref_extra=e
  compile_opt strictarr
  
  if (arg_present(focalPoint)) then focalPoint = self.focalPoint
  if (arg_present(aperture)) then aperture = self.aperture
  if (arg_present(blurSamples)) then blurSamples = self.blurSamples
  
  if (n_elements(e) gt 0L) then begin
    self->idlgrview::getProperty, _extra=e
  endif
end


;+
; Set properties.
;-
pro visgrpovrayview::setProperty, focal_point=focalPoint, $
                                  aperture=aperture, $
                                  blur_samples=blurSamples, $
                                  _extra=e
  compile_opt strictarr
  
  if (n_elements(focalPoint) gt 0L) then self.focalPoint = focalPoint
  if (n_elements(aperture) gt 0L) then self.aperture = aperture
  if (n_elements(blurSamples) gt 0L) then self.blurSamples = blurSamples
  
  if (n_elements(e) gt 0L) then begin
    self->idlgrview::setProperty, _extra=e
  endif
end


;+
; Create a POV-Ray view object.
;
; :Returns:
;    1 for success, 0 for failure
;-
function visgrpovrayview::init, focal_point=focalPoint, $
                                aperture=aperture, $
                                blur_samples=blurSamples, $
                                _extra=e 
                                  
  if (~self->idlgrview::init(_extra=e)) then return, 0
                                  
  if (n_elements(focalPoint) gt 0L) then self.focalPoint = focalPoint
  if (n_elements(aperture) gt 0L) then self.aperture = aperture
  if (n_elements(blurSamples) gt 0L) then self.blurSamples = blurSamples
  
  return, 1
end


;+
; Define instance variables.
;-                                  
pro visgrpovrayview__define
  compile_opt strictarr
  
  define = { VISgrPOVRayView, inherits IDLgrView, $
             focalPoint: fltarr(3), $
             aperture: 0.0, $
             blurSamples: 0L $
           }
end


; main-level example program of using the VISgrPOVRay class

; the FOCAL_POINT can't be set until the transforms of the scene are defined
view = obj_new('VISgrPOVRayView', name='view', color=[200, 200, 255], $
               aperture=0.4, blur_samples=20L)               

model = obj_new('IDLgrModel', name='model')
view->add, model

cowFilename = filepath('cow10.sav', subdir=['examples', 'data'])
restore, cowFilename
colors = randomu(seed, n_elements(x))
vertcolors = rebin(reform(255 * round(colors), 1, n_elements(x)), 3, n_elements(x))

cow = obj_new('IDLgrPolygon', x, y, z, polygons=polylist, $
              color=[255, 255, 255], shading=1, $
              vert_colors=vertcolors)
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

light = obj_new('IDLgrLight', type=2, location=[0, 5, 5], intensity=1.0)
model->add, light
alight = obj_new('IDLgrLight', type=0, intensity=1.0)
model->add, alight

; The focal point is not in data coords. It is necessary to calculate where the
; data coords of the focal point are transformed to, in this case:
; 
;   print, cow->getCTM() ## [0.52, 0.317, 0.0, 0.0]
; 
; where [0.52, 0.317, 0.0] are the data coords of the cow's head. Here
; VIS_TRANSFORMPOINT does this calculation for us.
view->setProperty, focal_point=vis_transformpoint([0.52, 0.317, 0.0], cow)

dims = [640, 480]

win = obj_new('IDLgrWindow', dimensions=dims, title='Object graphics View')
win->setProperty, graphics_tree=view
win->draw

pov = obj_new('VISgrPOVRay', file_prefix='view-output/view', dimensions=dims)
file_mkdir, 'view-output'
pov->draw, view

obj_destroy, pov

; create an image of the scene with:
;
;    $ povray +P +A view.ini

window, xsize=dims[0], ysize=dims[1], title='POV-Ray View'
viewImage = vis_povray('view-output/view')
tv, viewImage, true=1

end
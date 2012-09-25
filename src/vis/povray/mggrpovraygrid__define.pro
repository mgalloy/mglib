; docformat = 'rst'


;+
; A grid represents a plane with a grid pattern on it.
; 
; See the following for a discussion of how the grid is implemented in 
; POV-Ray::
;
;    http://tinyurl.com/4so8do
; 
; :Categories:
;    object graphics
;
; :Todo:
;   * Add an IDL representation of the grid
;
; :Examples:
;    The following creates a light blue plane with while grid lines at 
;    y = ymin with grid lines every 0.25 data units::
; 
;       plane = obj_new('MGgrPOVRayGrid', $
;                       gridline_thick=0.05, $
;                       color=[200, 200, 255], $
;                       gridline_color=[255, 255, 255], $
;                       grid_size=[0.25, 0.25], $
;                       plane=[0, 1, 0, -ymin])
;                
;    See the example attached to the end of this file as a main-level program 
;    (only available if you have the source code version of this routine)::
;
;       IDL> .run mggrpovraygrid__define
;
;    This should produce:
;
;    .. image:: grid.png
; 
; :Properties:
;    plane
;       equation of the plane [a, b, c, d] in the form::
;
;          ax + by + cz + d = 0
;
;    bottom
;       set to paint the grid lines on the other side of the plane; if the 
;       grid lines do not show up on the plane, use /BOTTOM
;    gridline_color
;       color of grid lines as an RGB triplet
;    gridline_thick
;       thickness of grid lines, 1.0 is the width of the grid cell
;    gridline_shift 
;       amount to shift the grid lines
;    grid_size
;       two-element array which is the size of the grid
;-


;+
; Finds a normal vector to a given vector.
;
; :Private:
; 
; :Returns:
;    fltarr(3)
;
; :Params:
;    v : in, required, type=fltarr(3)
;       vector to find a normal to
;-
function mggrpovraygrid::_findNormal, v
  compile_opt strictarr
  
  z = [0, 0, 1]
  y = [0, 1, 0]
  
  if (total(crossp(v, z)) eq 0L) then begin  ; v and z are parallel
    return, crossp(v, y)
  endif else begin
    return, crossp(v, z)
  endelse
end


;+
; Write POV-Ray description of the grid.
; 
; :Private:
; 
; :Params:
;    lun : in, required, type=long
;       logical unit number of file to write to
;-
pro mggrpovraygrid::write, lun
  compile_opt strictarr
  
  self->getProperty, color=color
  
  printf, lun, '#include "textures.inc"'
  printf, lun
  
  printf, lun, 'plane { <' + strjoin(strtrim(self.plane[0:2], 2), ', ')+ '>, ' + strtrim(-self.plane[3], 2)
  
  printf, lun, '  pigment {'
  printf, lun, '    Tiles_Ptrn()'
  printf, lun, '    color_map {
  printf, lun, '      [0.00 color ' + self->_getRGB(self.gridLineColor) + ']'
  printf, lun, '      [' + strtrim(self.gridLineThick, 2) + ' color ' + self->_getRGB(color)+ ']'  ; <0.8, 0.8, 0.5>
  printf, lun, '    }'
  printf, lun, '    scale <' + strjoin(strtrim(self.gridSize, 2), ', ') + ', 1.0>'
  if (~self.bottom) then begin
    normalVector = self->_findNormal(self.plane[0:2])
    printf, lun, '    rotate <' + strjoin(strtrim(normalVector, 2), ', ') +'>*90'
  endif
  printf, lun, '    translate <' + strjoin(strtrim(self.gridLineShift, 2), ', ') + '>'
  printf, lun, '  }' 

  self->_writeTransform, lun, self->getCTM()
  printf, lun, '}'

end


;+
; Get properties.
;-
pro mggrpovraygrid::getProperty, plane=plane, bottom=bottom, $
                                  gridline_color=gridLineColor, $
                                  gridline_thick=gridLineThick, $
                                  gridline_shift=gridLineShift, $                                
                                  grid_size=gridSize, $
                                  _ref_extra=e
  compile_opt strictarr
  
  if (arg_present(plane)) then plane = self.plane
  if (arg_present(bottom)) then bottom = self.bottom
  if (arg_present(gridLineColor)) then gridLineColor = self.gridLineColor
  if (arg_present(gridLineThick)) then gridLineThick = self.gridLineThick
  if (arg_present(gridLineShift)) then gridLineShift = self.gridLineShift
  if (arg_present(gridSize)) then gridSize = self.gridSize          

  if (n_elements(e) gt 0L) then begin
    self->idlgrpolygon::getProperty, _extra=e
  endif
end


;+
; Set properties.
;-
pro mggrpovraygrid::setProperty, plane=plane, bottom=bottom, $
                                  gridline_color=gridLineColor, $
                                  gridline_thick=gridLineThick, $
                                  gridline_shift=gridLineShift, $                                
                                  grid_size=gridSize, $
                                  _extra=e
  compile_opt strictarr
  
  if (n_elements(plane) gt 0L) then self.plane = plane
  if (n_elements(bottom) gt 0L) then self.bottom = bottom
  if (n_elements(gridLineColor) gt 0L) then self.gridLineColor = gridLineColor
  if (n_elements(gridLineThick) gt 0L) then self.gridLineThick = gridLineThick
  if (n_elements(gridLineShift) gt 0L) then self.gridLineShift = gridLineShift
  if (n_elements(gridSize) gt 0L) then self.gridSize = gridSize          
  
  if (n_elements(e) gt 0L) then begin
    self->idlgrpolygon::setProperty, _extra=e
  endif
end


;+
; Free resources.
;-
pro mggrpovraygrid::cleanup
  compile_opt strictarr
  
  self->idlgrpolygon::cleanup
end


;+
; Create a POV-Ray grid object.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mggrpovraygrid::init, plane=plane, bottom=bottom, $
                               gridline_color=gridLineColor, $
                               gridline_thick=gridLineThick, $
                               gridline_shift=gridLineShift, $                                
                               grid_size=gridSize, $
                               _extra=e 
                                  
  if (~self->idlgrpolygon::init(_extra=e)) then return, 0
  if (~self->MGgrPOVRayObject::init()) then return, 0
  
  self.gridLineColor = n_elements(gridLineColor) eq 0L ? bytarr(3) + 255B : gridLineColor
  self.gridLineShift = n_elements(gridLineShift) eq 0L ? fltarr(3) : gridLineShift  
  self.gridLineThick = n_elements(gridLineThick) eq 0L ? 0.03 : gridLineThick  
  self.gridSize = n_elements(gridSize) eq 0L ? fltarr(2) + 1.0 : gridSize
  self.plane = plane
  self.bottom = keyword_set(bottom)
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    plane
;       equation of the plane
;    bottom
;       set to switch the grid pattern to the other side of the plane
;    gridLineShift
;       amount to shift the grid in all three directions
;    gridLineColor
;       1 if open ended cylinders, 0 if closed
;    gridLineThick
;       thickness of grid lines as a fraction of grid size
;    gridSize
;       size of grid spacing
;-
pro mggrpovraygrid__define
  compile_opt strictarr

  define = { MGgrPOVRayGrid, $
             inherits IDLgrPolygon, inherits MGgrPOVRayObject, $
             plane: fltarr(4), $
             bottom: 0B, $
             gridLineShift: fltarr(3), $             
             gridLineColor: bytarr(3), $
             gridLineThick: 0.0, $
             gridSize: fltarr(2) $
           }
end



; main-level example program of using the `MGgrPOVRay` class

view = obj_new('IDLgrView', name='view', color=[200, 200, 255])

model = obj_new('IDLgrModel', name='model')
view->add, model

cowFilename = filepath('cow10.sav', subdir=['examples', 'data'])
restore, cowFilename
colors = randomu(seed, n_elements(x))
vertcolors = rebin(reform(255 * round(colors), 1, n_elements(x)), 3, n_elements(x))

cow = obj_new('IDLgrPolygon', x, y, z, polygons=polylist, $
              color=[150, 100, 20], shading=1, $
              shininess=25.0, ambient=[150, 100, 20], diffuse=[150, 100, 20])
model->add, cow

xmin = min(x, max=xmax)
xrange = xmax - xmin
ymin = min(y, max=ymax)
yrange = ymax - ymin
zmin = min(z, max=zmax)
zrange = zmax - zmin

plane = obj_new('MGgrPOVRayGrid', $
                gridline_thick=0.05, $
                color=[200, 200, 255], $
                gridline_color=[255, 255, 255], $
                grid_size=[0.25, 0.25], $
                plane=[0, 1, 0, -ymin])
model->add, plane

plane = obj_new('MGgrPOVRayGrid', $
                gridline_thick=0.05, $
                gridline_shift=[0, ymin, 0], $
                color=[255, 200, 200], $
                gridline_color=[255, 255, 255], $
                grid_size=[0.25, 0.25], $
                plane=[0, 0, 1, 1], /bottom)
model->add, plane

plane = obj_new('MGgrPOVRayGrid', $
                gridline_thick=0.05, $
                gridline_shift=[0, ymin, 0], $
                color=[200, 255, 200], $
                gridline_color=[255, 255, 255], $
                grid_size=[0.25, 0.25], $
                plane=[1, 0, 0, 1])
model->add, plane

model->rotate, [0, 1, 0], -45
model->rotate, [1, 0, 0], 10

lightModel = obj_new('IDLgrModel')
view->add, lightModel

light = obj_new('IDLgrLight', type=2, $
                location=[0, 3, 3], intensity=1.0)
lightModel->add, light

alight = obj_new('IDLgrLight', type=0, intensity=1.0)
lightModel->add, alight

dims = [640, 480]

win = obj_new('IDLgrWindow', dimensions=dims, title='Object graphics Grid')
win->setProperty, graphics_tree=view
win->draw

pov = obj_new('MGgrPOVRay', file_prefix='grid-output/grid', dimensions=dims)
file_mkdir, 'grid-output'
pov->draw, view

obj_destroy, pov

; create an image of the scene with:
;
;    $ povray +P +A grid.ini

window, xsize=dims[0], ysize=dims[1], title='POV-Ray Grid', /free
cowImage = mg_povray('grid-output/grid')
tv, cowImage, true=1

end

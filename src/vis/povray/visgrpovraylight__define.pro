; docformat = 'rst'

;+
; Any IDL type of light source plus the POV-Ray area light.
; 
; :Categories:
;    object graphics
;
; :Examples:
;    To create an area light::
;      
;       light = obj_new('VISgrPOVRayLight', type=2, location=[0, 5, 5], $
;                       intensity=2.0, $
;                       /arealight, $
;                       width_axis=[0.3, 0, 0], height_axis=[0, 0.3, 0], $
;                       n_width_light=5, n_height_lights=5, $
;                       adaptive=1.0, /jitter)
;    
;    This light is actually a 5 by 5 grid of lights spanning 0.3 units in the
;    x direction and 0.3 units in the y direction (although each light is 
;    moved slightly by the JITTER keyword). This creates softer shadows.
;                
;    See the example attached to the end of this file as a main-level program 
;    (only available if you have the source code version of this routine)::
;       
;       IDL> .run visgrpovraylight__define
;        
;    This should produce output with an area light (which makes a fuzzy 
;    shadow):
;    
;    .. image:: arealight.png
;    
; :Properties:
;    arealight
;       set to use an area light
;    width_axis
;       vector representing width of area light
;    height_axis
;       vector representing height of area light
;    n_width_lights
;       number of lights along width axis
;    n_height_lights
;       number of lights along height axis
;    adaptive
;       adaptive value
;    jitter
;       set to use jitter
;-


;+
; Get properties.
;-
pro visgrpovraylight::getProperty, arealight=arealight, $
                                   width_axis=widthAxis, $
                                   height_axis=heightAxis, $
                                   n_width_lights=nWidthLights, $
                                   n_height_lights=nHeightLights, $
                                   adaptive=adaptive, jitter=jitter, $
                                  _ref_extra=e
  compile_opt strictarr
  
  if (arg_present(arealight)) then arealight = self.arealight
  if (arg_present(widthAxis)) then widthAxis = self.widthAxis
  if (arg_present(heightAxis)) then heightAxis = self.heightAxis
  if (arg_present(nWidthLights)) then nWidthLights = self.nWidthLights
  if (arg_present(nHeightLights)) then nHeightLights = self.nHeightLights
  if (arg_present(adaptive)) then adaptive = self.adaptive
  if (arg_present(jitter)) then jitter = self.jitter            

  if (n_elements(e) gt 0L) then begin
    self->idlgrlight::getProperty, _extra=e
  endif
end


;+
; Set properties.
;-
pro visgrpovraylight::setProperty, arealight=arealight, $
                                   width_axis=widthAxis, $
                                   height_axis=heightAxis, $
                                   n_width_lights=nWidthLights, $
                                   n_height_lights=nHeightLights, $
                                   adaptive=adaptive, jitter=jitter, $
                                   _extra=e
  compile_opt strictarr
  
  if (n_elements(arealight) gt 0L) then self.arealight = arealight       
  if (n_elements(widthAxis) gt 0L) then self.widthAxis = widthAxis       
  if (n_elements(heightAxis) gt 0L) then self.heightAxis = heightAxis       
  if (n_elements(nWidthLights) gt 0L) then self.nWidthLights = nWidthLights       
  if (n_elements(nHeightLights) gt 0L) then self.nHeightLights = nHeightLights       
  if (n_elements(adaptive) gt 0L) then self.adaptive = adaptive       
  if (n_elements(jitter) gt 0L) then self.jitter = jitter                   
  
  if (n_elements(e) gt 0L) then begin
    self->idlgrlight::setProperty, _extra=e
  endif
end


;+
; Write out the POV-Ray description of an area light.
; 
; :Private:
; 
; :Params:
;    lun : in, required, type=long
;       logical unit number to write to
;-
pro visgrpovraylight::_writeArealight, lun
  compile_opt strictarr

  if (self.arealight) then begin
    printf, lun, '  area_light ' $
              + '<' + strjoin(strtrim(self.widthAxis, 2), ', ') + '>, ' $
              + '<' + strjoin(strtrim(self.heightAxis, 2), ', ')+ '>, ' $
              + strtrim(self.nWidthLights, 2) + ', ' $
              + strtrim(self.nHeightLights, 2)
    printf, lun, '  adaptive ' + strtrim(self.adaptive, 2)
    if (self.jitter) then printf, lun, '  jitter'
  endif  
end


;+
; Write out the POV-Ray description of the light.
; 
; :Private:
; 
; :Params:
;    lun : in, required, type=long
;       logical unit number to write to
;-
pro visgrpovraylight::write, lun
  compile_opt strictarr

  self->getProperty, type=type, intensity=intensity, color=color, $ 
                     location=location
  
  intensity *= self.lightIntensityMultiplier
  
  ; TODO: handle positional lights and spotlights
  case type of
    0: ; ambient, already taken care of
    1: ; positional
    2: begin ; directional
        sLocation = strjoin(strtrim(location, 2), ',')
        printf, lun, 'light_source {' 
        printf, lun, '  <' +  sLocation + '>'
        printf, lun, '  color ' + self->_getRGB(color) + ' * ' + strtrim(intensity, 2) 
        
        self->_writeAreaLight, lun        
        self->_writeTransform, lun, self->getCTM()
        printf, lun, '}' 
      end
    3: ; spotlight
    else: message, 'unknown light source type'
  endcase 
end


;+
; Create a light object.
;
; :Returns:
;    1 for success, 0 for failure
;-
function visgrpovraylight::init, arealight=arealight, $
                                 width_axis=widthAxis, $
                                 height_axis=heightAxis, $
                                 n_width_lights=nWidthLights, $
                                 n_height_lights=nHeightLights, $
                                 adaptive=adaptive, jitter=jitter, $
                                 _extra=e
  compile_opt strictarr

  if (~self->idlgrlight::init(_extra=e)) then return, 0
  if (~self->VISgrPOVRayObject::init()) then return, 0

  ; set default values
  self.arealight = keyword_set(arealight)
  self.widthAxis = n_elements(widthAxis) eq 0L ? [1., 0., 0.] : widthAxis
  self.heightAxis = n_elements(heightAxis) eq 0L ? [1., 0., 0.] : heightAxis
  self.nWidthLights = n_elements(nWidthLights) eq 0L ? 3 : nWidthLights
  self.nHeightLights = n_elements(nHeightLights) eq 0L ? 3 : nHeightLights  
  self.adaptive = n_elements(adaptive) eq 0L ? 1.0 : adaptive
  self.jitter = keyword_set(jitter)
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    arealight
;       set to use an area light
;    widthAxis
;       vector representing width of area light
;    heightAxis
;       vector representing height of area light
;    nWidthLights
;       number of lights along the width axis
;    nHeightLights
;       number of lights along the height axis
;    adaptive
;       adaptive value
;    jitter
;       set to jitter lights
;-
pro visgrpovraylight__define
  compile_opt strictarr
  
  define = { VISgrPOVRayLight, $
             inherits IDLgrLight, inherits VISgrPOVRayObject, $
             arealight: 0B, $
             widthAxis: fltarr(3), $
             heightAxis: fltarr(3), $
             nWidthLights: 0L, $
             nHeightLights: 0L, $
             adaptive: 0.0, $
             jitter: 0B $
           }
end


; example of using the VISgrPOVRay class

view = obj_new('IDLgrView', name='view', color=[200, 200, 255])

model = obj_new('IDLgrModel', name='model')
view->add, model

cowFilename = filepath('cow10.sav', subdir=['examples', 'data'])
restore, cowFilename
colors = randomu(seed, n_elements(x))
vertcolors = rebin(reform(255 * round(colors), 1, n_elements(x)), 3, n_elements(x))

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

light = obj_new('VISgrPOVRayLight', type=2, location=[0, 5, 5], intensity=1.0, $
                /arealight, width_axis=[0.3, 0, 0], height_axis=[0, 0.3, 0], $
                n_width_light=5, n_height_lights=5, $
                adaptive=1.0, /jitter)
model->add, light
alight = obj_new('IDLgrLight', type=0, intensity=1.0)
model->add, alight

dims = [640, 480]

win = obj_new('IDLgrWindow', dimensions=dims, title='Object graphics Arealight')
win->setProperty, graphics_tree=view
win->draw

pov = obj_new('VISgrPOVRay', file_prefix='arealight-output/arealight', dimensions=dims)
file_mkdir, 'arealight-output'
pov->draw, view

obj_destroy, pov

; create an image of the scene with:
;
;    $ povray +P +A arealight.ini

window, xsize=dims[0], ysize=dims[1], title='POV-Ray Arealight'
arealightImage = vis_povray('arealight-output/arealight')
tv, arealightImage, true=1

end
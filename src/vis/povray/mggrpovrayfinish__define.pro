; docformat = 'rst'

;+
; Attribute class for `MGgrPOVRayPolygons` representing the surface properties
; of objects.
; 
; :Categories:
;    object graphics
;
; :Examples:
;    To create a finish object using one of the finishes named in finish.inc,
;    use::
;    
;       finish = obj_new('MGgrPOVRayFinish', finish_name='F_MetalB')
;
;    This can then be used in one of the `MGgrPOVRay` classes like::
;
;       cow = obj_new('MGgrPOVRayPolygon', x, y, z, polygons=polylist, $
;                      color=[150, 100, 20], shading=1, $
;                      shininess=25.0, ambient=[150, 100, 20], diffuse=[150, 100, 20], $
;                      finish=finish)
;              
;    See the example attached to the end of this file as a main-level program 
;    (only available if you have the source code version of this routine)::
;
;       IDL> .run mggrpovraygrid__define
;
;    This should produce:
;
;    .. image:: metal.png
;    
; :Properties:
;    finish_name
;       name of a finish in finish.inc
;    ambient
;       controls the amount of ambient light that falls on the surface; 
;       increase this amount to increase details in shadows; default value is 
;       0.2
;    diffuse
;       controls the amount of light from a light source falls on the surface;
;       low values of DIFFUSE will make the surface appear flat; default value
;       is 0.6
;    brilliance
;       controls the way that light intensity varies with incidence angle; the
;       default value is 1.0, higher values will cause the light to fall of 
;       less at low and medium angles of incidence 
;    metallic
;       set to give the surface a more metallic appearance; default value is 
;       not metallic
;    specular
;       controls specular highlights in conjunction with ROUGHNESS; controls 
;       the brightness of the specular highlight; default value is 0.0
;    roughness
;       controls specular highlights in conjunction with SPECULAR; controls 
;       the size of the specular highlight, small values make small, tight 
;       specular highlights; default value is 0.05
;    reflection
;       amount the surface reflects; generally reflection and diffuse should
;       be inversely proportional; default value is 0.0
;    irid_amount
;       amount of contribution of iridescence to overall surface color, 
;       usually 0.1 to 0.5 is sufficient; iridescence is not used by default, 
;       but if any iridescence property is set it is used; default value is 
;       0.35
;    irid_thickness
;       thickness affects busyness of the iridescence, 0.25 to 1.0 yields best
;       results; iridescence is not used by default, but if any iridescence 
;       property is set it is used; default value is 0.5
;    irid_turbulence
;       slightly difference way to affect thickness, 0.25 to 1.0 work best; 
;       iridescence is not used by default, but if any iridescence property is
;       set it is used; default value is 0.5
;-

  
;+
; Returns true if the finish is given by name instead of property values.
; 
; :Private:
; 
; :Returns:
;    1 if finish_name is used, 0 if not
;-
function mggrpovrayfinish::hasName
  compile_opt strictarr

  return, self.finishName ne ''
end


;+
; Write the finish properties to a file.
; 
; :Private:
; 
; :Params:
;    lun : in, required, type=long
;       logical unit number to write to
;-
pro mggrpovrayfinish::write, lun
  compile_opt strictarr
  
  if (self.finishName ne '') then begin
    printf, lun, '  finish { ' + self.finishName + ' }'
  endif else begin
    printf, lun, '  finish {'
    printf, lun, '    ambient ' + strtrim(self.ambient, 2)
    printf, lun, '    brilliance ' + strtrim(self.brilliance, 2)
    printf, lun, '    diffuse ' + strtrim(self.diffuse, 2)
    if (self.metallic) then printf, lun, '    metallic'
    printf, lun, '    specular ' + strtrim(self.specular, 2) 
    printf, lun, '    roughness ' + strtrim(self.roughness, 2)
    printf, lun, '    reflection ' + strtrim(self.reflection, 2)
    
    if (self.hasIrid) then begin
      printf, lun, '    irid {'
      printf, lun, '      ' + strtrim(self.iridAmount, 2)
      printf, lun, '      thickness ' + strtrim(self.iridThickness, 2)
      printf, lun, '      turbulence ' + strtrim(self.iridTurbulence, 2)      
      printf, lun, '    }'
    endif
    
    printf, lun, '  }'
  endelse  
end


;+
; Get properties.
;-
pro mggrpovrayfinish::getProperty, finish_name=finishName, $
                                   ambient=ambient, brilliance=brilliance, $
                                   diffuse=diffuse, metallic=metallic, $
                                   specular=specular, roughness=roughness, $
                                   reflection=reflection, $
                                   irid_amount=iridAmount, $
                                   irid_thickness=iridThickness, $
                                   irid_turbulence=iridTurbulence                                    
  compile_opt strictarr
  
  if (arg_present(finishName)) then finishName = self.finishName
  if (arg_present(ambient)) then ambient = self.ambient
  if (arg_present(brilliance)) then brilliance = self.brilliance
  if (arg_present(diffuse)) then diffuse = self.diffuse
  if (arg_present(metallic)) then metallic = self.metallic
  if (arg_present(specular)) then specular = self.specular
  if (arg_present(roughness)) then roughness = self.roughness
  if (arg_present(reflection)) then reflection = self.reflection
  
  if (arg_present(iridAmount)) then iridAmount = self.iridAmount
  if (arg_present(iridThickness)) then iridThickness = self.iridThickness
  if (arg_present(iridTurbulence)) then iridTurbulence = self.iridTurbulence
end


;+
; Set properties.
;-
pro mggrpovrayfinish::setProperty, finish_name=finishName, $
                                   ambient=ambient, brilliance=brilliance, $
                                   diffuse=diffuse, metallic=metallic, $
                                   specular=specular, roughness=roughness, $
                                   reflection=reflection, $
                                   irid_amount=iridAmount, $
                                   irid_thickness=iridThickness, $
                                   irid_turbulence=iridTurbulence
  compile_opt strictarr
  
  if (n_elements(finishName) gt 0L) then self.finishName = finishName
  if (n_elements(ambient) gt 0L) then self.ambient = ambient
  if (n_elements(brilliance) gt 0L) then self.brilliance = brilliance
  if (n_elements(diffuse) gt 0L) then self.diffuse = diffuse
  if (n_elements(metallic) gt 0L) then self.metallic = keyword_set(metallic)
  if (n_elements(specular) gt 0L) then self.specular = specular
  if (n_elements(roughness) gt 0L) then self.roughness = roughness
  if (n_elements(reflection) gt 0L) then self.reflection = reflection  

  self.hasIrid = self.hasIrid $
                   || (n_elements(iridAmount) gt 0L) $
                   || (n_elements(iridThickness) gt 0L) $
                   || (n_elements(iridTurbulence) gt 0L)                   
  if (n_elements(iridAmount) gt 0L) then self.iridAmount = iridAmount  
  if (n_elements(iridThickness) gt 0L) then self.iridThickness = iridThickness  
  if (n_elements(iridTurbulence) gt 0L) then self.iridTurbulence = iridTurbulence                     
end


;+
; Create a finish.
; 
; :Returns:
;    1 for success, 0 for failure
;-
function mggrpovrayfinish::init, finish_name=finishName, $
                                 ambient=ambient, brilliance=brilliance, $
                                 diffuse=diffuse, metallic=metallic, $
                                 specular=specular, roughness=roughness, $
                                 reflection=reflection, $
                                 irid_amount=iridAmount, $
                                 irid_thickness=iridThickness, $
                                 irid_turbulence=iridTurbulence
  compile_opt strictarr
  
  if (~self->MGgrPOVRayObject::init()) then return, 0
  
  self.finishName = n_elements(finishName) eq 0L ? '' : finishName

  self.ambient = n_elements(ambient) eq 0L ? 0.2 : ambient
  self.brilliance = n_elements(brilliance) eq 0L ? 1.0 : brilliance
  self.diffuse = n_elements(diffuse) eq 0L ? 0.6 : diffuse
  self.metallic = keyword_set(metallic)
  self.specular = n_elements(specular) eq 0L ? 0.0 : specular
  self.roughness = n_elements(roughness) eq 0L ? 0.05 : roughness
  self.reflection = n_elements(reflection) eq 0L ? 0.0 : reflection  

  self.hasIrid = (n_elements(iridAmount) gt 0L) $
                   || (n_elements(iridThickness) gt 0L) $
                   || (n_elements(iridTurbulence) gt 0L)
  self.iridAmount = n_elements(iridAmount) eq 0L ? 0.35 : iridAmount
  self.iridThickness = n_elements(iridThickness) eq 0L ? 0.5 : iridThickness                   
  self.iridTurbulence = n_elements(iridTurbulence) eq 0L ? 0.5 : iridTurbulence
                     
  return, 1
end


;+
; Define instance variables.
; 
; :Fields:
;    finishName
;       name of finish in finish.inc
;    ambient
;       controls the amount of ambient light that falls on the surface
;    diffuse
;       controls the amount of light from a light source falls on the surface
;    brilliance
;       controls how angle of incidence affects light fall off
;    metallic
;       set if metallic
;    specular
;       brigtness of specular highlight
;    roughness
;       size of specular highlight
;    reflection
;       amount of reflection
;    hasIrid
;       set if any iridescense property has been set
;    iridAmount
;       amount of iridescense
;    iridThickness
;       amount of busyness of iridescense
;    iridTurbulence
;       another way to affect thicness of iridescense
;-
pro mggrpovrayfinish__define
  compile_opt strictarr
  
  define = { MGgrPOVRayFinish, inherits MGgrPOVRayObject, $
             finishName: '', $
             ambient: 0.0, $
             brilliance: 0.0, $
             diffuse: 0.0, $
             metallic: 0B, $
             specular: 0.0, $
             roughness: 0.0, $
             reflection: 0.0, $
             hasIrid: 0B, $
             iridAmount: 0.0, $
             iridThickness: 0.0, $
             iridTurbulence: 0.0 $
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

finish = obj_new('MGgrPOVRayFinish', finish_name='F_MetalB')

cow = obj_new('MGgrPOVRayPolygon', x, y, z, polygons=polylist, $
              color=[150, 100, 20], shading=1, $
              ;vert_colors=vertcolors, clip_planes=[0, 0, 1, 0], $
              shininess=25.0, ambient=[150, 100, 20], diffuse=[150, 100, 20], $
              finish=finish)
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

model->rotate, [0, 1, 0], -45
model->rotate, [1, 0, 0], 30

light = obj_new('IDLgrLight', type=2, location=[0, 5, 5], intensity=1.0)
model->add, light
alight = obj_new('IDLgrLight', type=0, intensity=1.0)
model->add, alight

dims = [640, 480]

win = obj_new('IDLgrWindow', dimensions=dims, title='Object graphics Metal Cow')
win->setProperty, graphics_tree=view
win->draw

pov = obj_new('MGgrPOVRay', file_prefix='metal-output/metal', dimensions=dims)
file_mkdir, 'metal-output'
pov->draw, view

obj_destroy, pov

; create an image of the scene with:
;
;    $ povray +P +A metal.ini

window, xsize=dims[0], ysize=dims[1], title='POV-Ray Metal Cow', /free
cowImage = mg_povray('metal-output/metal')
tv, cowImage, true=1

end

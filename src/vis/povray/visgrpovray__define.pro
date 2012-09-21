; docformat = 'rst'

;+
; This class is a POV-Ray object graphics destination. Drawing to this 
; destination will create one .inc file for every atom in the object graphics 
; hierarchy, a .pov file with the scene setup, and a .ini file with some 
; parameters like output dimensions.
;
; :Categories:
;    object graphics
; 
; :Examples:
;    To create a POV-Ray destination and drawing to it after creating an object
;    graphics hierarchy, view, just do the following::
;    
;       pov = obj_new('VISgrPOVRay', file_prefix='cow-output/cow', dimensions=dims)
;       pov->draw, view
;       
;    See the example attached to the end of this file as a main-level program 
;    (only available if you have the source code version of this routine)::
; 
;       IDL> .run visgrpovray__define
;
;    The example should produce a png file, cow.png::
;
;    .. image:: cow-example.png
; 
; :Properties:
;    file_prefix
;       prefix to add to all output files; final result will be::
;
;          file_prefix + '.png'
;
;    dimensions
;       lonarr(2) specifying default width and height of output image; default
;       value is [400, 400]
;    graphics_tree
;       graphics tree to render if none is provided to draw method
;-


;+
; Create a unique name for the given object's .inc file.
; 
; :Private:
; 
; :Returns:
;    string filename for object
;
; :Params:
;    object : in, required, type=object
;       object graphics atom object
;    prefix : in, required, type=string
;       string prefix for the name
;-
function visgrpovray::_getFilename, object, prefix
  compile_opt strictarr

  object->getProperty, name=name
  name = (n_elements(name) eq 0 || strlen(name) eq 0) $
         ? strlowcase(obj_class(object)) $
         : name  
  
  filename = prefix + '_' + name + '.inc'
  
  i = 2L
  while (file_test(filename)) do begin
    filename = prefix + '_' + name + '-' + strtrim(i++, 2) + '.inc'
  endwhile  
  
  return, filename
end


;+
; Helper method to write the output for any of the VISgrPOVRayXXXX classes.
; 
; :Private:
; 
; :Params:
;    povObject : in, required, type=object
;       VISgrPOVRayXXXX object with a write method
;    prefix : in, required, type=string
;       prefix (i.e. filename without the .inc extension) to write to
;       
; :Keywords:
;    includes : in, out, required, type=strarr
;       list of files to include in the .pov file; undefined to represent the
;       empty list
;-
pro visgrpovray::_writePOVObject, povObject, prefix, includes=includes
  compile_opt strictarr
  
  ; get a filename and add it to the includes list for the .pov file
  filename = self->_getFilename(povObject, prefix)
  includes = n_elements(includes) eq 0 ? [filename] : [includes, filename]
  
  ; write the .inc file
  openw, lun, filename, /get_lun
  povObject->write, lun
  free_lun, lun    
end


;+
; Writes output for a subclass of IDLgrSurface.
;
; :Private:
; 
; :Params:
;    surface : in, required, type=object
;       subclass of IDLgrSurface
;    prefix : in, required, type=string
;       path to polygon object
;
; :Keywords:
;    includes : in, out, required, type=strarr
;       list of files to include in the .pov file; undefined to represent the
;       empty list
;-
pro visgrpovray::_writeSurface, surface, prefix, includes=includes
  compile_opt strictarr
  
  surface->getProperty, data=data, color=color, style=style, $
                        shading=shading

  filename = self->_getFilename(surface, prefix)
                        
  ; write data out as a .png file, pull just the z-coordinates out of the 
  ; data property
  pngFilename = file_basename(filename, '.inc') + '.png'
  write_png, pngFilename, bytscl(reform(data[2, *, *]))   ; 2 -> z-coords
  
  ; write the .inc file
  
  includes = n_elements(includes) eq 0 ? [filename] : [includes, filename]
  
  openw, lun, filename, /get_lun
  printf, lun, 'height_field {'
  printf, lun, '  png "' + pngFilename + '"'
  printf, lun, '  smooth'
  printf, lun, '  pigment { ' + self->_getRgb(color) + ' }'
  
  self->_writeTransform, lun, surface->getCTM()
    
  printf, lun, '}'
  free_lun, lun
end


;+
; Writes output for a subclass of IDLgrPolygon.
;
; :Private:
; 
; :Params:
;    polygon : in, required, type=object
;       subclass of IDLgrPolygon
;    prefix : in, required, type=string
;       path to polygon object
;
; :Keywords:
;    includes : in, out, required, type=strarr
;       list of files to include in the .pov file; undefined to represent the
;       empty list
;-
pro visgrpovray::_writePolygon, polygon, prefix, includes=includes
  compile_opt strictarr
  on_error, 2
  
  polygon->getProperty, data=vertices, normals=normals, polygons=polygons, $
                        color=color, shading=shading, $
                        texture_map=textureMap, texture_coord=textureCoord, $
                        vert_colors=vertcolors, $
                        xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc, $
                        clip_planes=clipPlanes, $
                        alpha_channel=alphaChannel, $
                        shininess=shininess, ambient=ambient, $
                        diffuse=diffuse, $
                        specular=specular, emission=emission
  
  hasVertColors = vertcolors[0] ne -1L  
  hasTextureMap = obj_valid(textureMap)

  szVertices = size(vertices, /structure)
  nVertices = szVertices.dimensions[1]
  
  if (polygons[0] eq -1L) then polygons = [nVertices, lindgen(nVertices)]
  
  ntriangles = mesh_validate(vertices, polygons)
  
  filename = self->_getFilename(polygon, prefix)
  includes = n_elements(includes) eq 0 ? [filename] : [includes, filename]
  
  openw, lun, filename, /get_lun
  printf, lun, 'mesh2 {'
  
  self->_writeVertices, lun, vertices, name='vertex_vectors'
  
  case shading of
    0: 
    1: self->_writeVertices, lun, compute_mesh_normals(vertices, polygons), $
                             name='normal_vectors'      
    else: message, 'unknown shading method'
  endcase

  if (hasTextureMap) then begin
    ncoords = product((size(textureCoord, /dimensions))[1:*])
    tcoord = reform(textureCoord, 2, ncoords)
    self->_writeVertices, lun, tcoord, name='uv_vectors'    
  endif
  
  ; write texture_list if polygon has vert_colors
  if (hasVertColors) then begin
    tSize = size(vertcolors, /structure)
    printf, lun
    printf, lun, '  texture_list {'
    printf, lun, '    ' + strtrim(tSize.dimensions[1], 2) + ','
    pre = '    texture { pigment { '
    post = ' }}'
    for t = 0L, tSize.dimensions[1] - 1L do begin
      printf, lun, pre + self->_getRGB(vertcolors[*, t], alpha_channel=alphaChannel) + post
    endfor
    printf, lun, '  }'
    printf, lun
  endif
  
  ; count polygons
  nPolygons = 0L
  nPolyElements = n_elements(polygons)
  p = 0L
  while (p lt nPolyElements) do begin
    p += polygons[p] + 1L
    nPolygons++
  endwhile

  printf, lun
  printf, lun, '  face_indices {'
  printf, lun, '    ' + strtrim(nPolygons, 2) + ','
  p = 0L
  while (p lt nPolyElements) do begin
    poly = polygons[p + 1L: p + polygons[p]]
    p += polygons[p] + 1L    
    comma = p eq nPolyElements ? '' : ','    
    coords = strjoin(strtrim(poly, 2), ',')
    printf, lun, '    <' + coords + '>' $               ; coords
              + (hasVertColors ? ',' + coords : '') $   ; vert colors
              + comma                                   ; comma, unless last
  endwhile
  printf, lun, '  }'

  if (n_elements(clipPlanes) ne 1L) then begin
    printf, lun, '  clipped_by { plane { <' + strjoin(strtrim(clipPlanes[0:2], 2), ', ') + '>, ' + strtrim(-clipPlanes[3], 2) + '}}'    
  endif
  
  self->_writeTransform, lun, polygon->getCTM()
  
  ; TODO: use emission for radiosity
  
  ; use image_map for texture maps
  if (hasTextureMap) then begin
    textureMap->getProperty, data=im, palette=palette, interleave=interleave, $
                             greyscale=greyscale
    if (obj_valid(palette) && size(im, /n_dimensions) eq 2L && ~greyscale) then begin
      palette->getProperty, red_values=r, green_values=g, blue_values=b
      _im = vis_maketrue(im, red=r, green=g, blue=b, true=interleave + 1L)
    endif else begin
      _im = im
    endelse
    
    texFilename = strmid(filename, 0L, strlen(filename) - 4L) + '-texture.png'
    printf, lun
    printf, lun, '  uv_mapping'
    printf, lun, '  pigment { image_map { png "' + file_basename(texFilename) + '" }}'
    printf, lun
    write_png, texFilename, _im
  endif else begin  
    printf, lun
    printf, lun, '   pigment { ' + self->_getRgb(color, alpha_channel=alphaChannel) + ' }'
  endelse
  
  printf, lun, '   finish {'
  printf, lun, '      phong ' + strtrim(shininess / 128.0, 2)
  printf, lun, '      phong_size ' + strtrim(shininess, 2)  
  printf, lun, '   }'  
  printf, lun, '}'
  
  free_lun, lun
end


;+
; Writes output for a subclass of IDLgrPolyline.
;
; :Private:
; 
; :Params:
;    polyline : in, required, type=object
;       subclass of IDLgrPolygon
;    prefix : in, required, type=string
;       path to polygon object
;
; :Keywords:
;    includes : in, out, required, type=strarr
;       list of files to include in the .pov file; undefined to represent the
;       empty list
;-
pro visgrpovray::_writePolyline, polyline, prefix, includes=includes
  compile_opt strictarr
  on_error, 2
  
  polyline->getProperty, data=vertices, color=color, vert_colors=vertColors, $
                         symbol=symbol, linestyle=linestyle, $
                         xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc
  
  szVertices = size(vertices, /structure)
  nVertices = szVertices.dimensions[1]
  
  filename = self->_getFilename(polyline, prefix)
  includes = n_elements(includes) eq 0 ? [filename] : [includes, filename]
  
  openw, lun, filename, /get_lun
  
  ; produce a warning if LINESTYLE not "no line"
  if (linestyle ne 6L) then begin
    message, 'ignoring IDLgrPolyline LINESTYLE, use VISgrPOVRayTubes instead', $
             /informational
  endif
  
  ; draw symbols
  nsymbols = n_elements(symbol)
  if (nsymbols gt 0L) then begin    
    symsizes = fltarr(nsymbols)
    for i = 0L, nsymbols - 1L do begin
      if (obj_valid(symbol[i])) then begin
        symbol[i]->getProperty, size=ssize
      endif else begin
        ssize = 1.
      endelse
      symsizes[i] = ssize[0]   ; only using x size if 2- or 3-dimensional size
    endfor
    
    for v = 0L, nVertices - 1L do begin
      printf, lun, strjoin(strtrim(vertices[*, v], 2), ', '), $
                   symsizes[v mod nsymbols], $
                   format='(%"sphere { <%s>, %f")'
      self->_writeTransform, lun, polyline->getCTM()
      printf, lun
    
      if (n_elements(vertColors) gt 1L) then begin
        printf, lun, '  pigment { ' + self->_getRgb(vertColors[*, v]) + ' }'      
      endif else begin
        printf, lun, '  pigment { ' + self->_getRgb(color) + ' }'
      endelse
  
      printf, lun, '}'
      printf, lun
    endfor
  endif
  
  free_lun, lun
end


;+
; Writes output for a subclass of IDLgrLight.
;
; :Private:
; 
; :Params:
;    light : in, required, type=object
;       subclass of IDLgrLight
;    prefix : in, required, type=string
;       path to polygon object
;
; :Keywords:
;    includes : in, out, required, type=strarr
;       list of files to include in the .pov file; undefined to represent the
;       empty list
;-
pro visgrpovray::_writeLight, light, prefix, includes=includes
  compile_opt strictarr
  on_error, 2
  
  light->getProperty, type=type, intensity=intensity, color=color, $ 
                      location=location

  intensity *= self.lightIntensityMultiplier
                     
  ; ambient light is special since it is handled in the "global_settings"     
  if (type eq 0L) then begin
    self.ambientIntensity = intensity
    return
  endif
  
  self.hasLight = 1B
  
  filename = self->_getFilename(light, prefix)
  includes = n_elements(includes) eq 0 ? [filename] : [includes, filename]

  openw, lun, filename, /get_lun  
  
  ; TODO: handle positional lights and spotlights
  case type of
    0: ; ambient, already taken care of
    1: ; positional
    2: begin ; directional
        sLocation = strjoin(strtrim(location, 2), ',')
        printf, lun, 'light_source {' 
        printf, lun, ' <' +  sLocation + '> color ' + self->_getRGB(color) + ' * ' + strtrim(intensity, 2) 
        self->_writeTransform, lun, light->getCTM()
        printf, lun, '  }' 
      end
    3: ; spotlight
    else: message, 'unknown light source type'
  endcase
  
  free_lun, lun  
end


;+
; Writes output for a subclass of IDLgrText.
;
; :Private:
; 
; :Params:
;    text : in, required, type=object
;       subclass of IDLgrText
;    prefix : in, required, type=string
;       path to polygon object
;
; :Keywords:
;    includes : in, out, required, type=strarr
;       list of files to include in the .pov file; undefined to represent the
;       empty list
;-
pro visgrpovray::_writeText, text, prefix, includes=includes
  compile_opt strictarr
  on_error, 2

  text->getProperty, strings=strings, color=color, font=font, locations=loc
  
  if (obj_valid(font)) then begin
    font->getProperty, size=fontSize
  endif else fontSize = 12.0
  
  ; find parent view
  parent = text
  while (~obj_isa(parent, 'IDLgrView')) do parent->getProperty, parent=parent
  parent->getProperty, viewplane_rect=vpr
  
  htPixels = fontSize / 72.0 * !d.y_px_cm * 2.54
  scaleFactor = htPixels * vpr[2] / self.dimensions[1]
  scale = diag_matrix([fltarr(3) + scaleFactor, 1.0])
  ctm = text->getCTM() ## scale
  
  filename = self->_getFilename(text, prefix)
  includes = n_elements(includes) eq 0 ? [filename] : [includes, filename]

  openw, lun, filename, /get_lun  
  
  for s = 0L, n_elements(strings) - 1L do begin
    ctm[3, 0] = transpose(loc[*, s])
    
    printf, lun, 'text {'
    printf, lun, '  ttf "timrom.ttf" "' + strings[s] + '" 0.01, 0'
    printf, lun, '  pigment { ' + self->_getRgb(color) + ' }'
    self->_writeTransform, lun, ctm
    printf, lun, '}'
  endfor

  free_lun, lun    
end


;+
; Write the .pov file.
;
; :Private:
; 
; :Params:
;    tree : in, required, type=object
;       object graphics tree to traverse
;
; :Keywords:
;    includes : in, out, required, type=strarr
;       list of files to include in the .pov file; undefined to represent the
;       empty list
;-
pro visgrpovray::_writePov, tree, includes=includes
  compile_opt strictarr

  filename = self.filePrefix + '.pov'
  openw, lun, filename, /get_lun
  
  for i = 0L, n_elements(includes) - 1L do begin
    printf, lun, '#include "' + file_basename(includes[i]) + '"'
  endfor

  if (~self.hasLight || self.ambientIntensity gt 0.0) then begin
    intensity = self.hasLight ? self.ambientIntensity : 1.0
    printf, lun
    printf, lun, 'global_settings { ambient_light rgb <1.0, 1.0, 1.0> * ' $
                   + strtrim(intensity, 2) + ' }'
  endif
  
  printf, lun, 'background { color ' + self->_getRGB(self.background) + ' }'
  
  aspectRatio = float(self.dimensions[0]) / float(self.dimensions[1])
  
  printf, lun
  printf, lun, 'camera {'
  printf, lun, '  location <' + strjoin(strtrim(self.location, 2), ', ') + '>'
  printf, lun, '  right <-' + strtrim(aspectRatio, 2) + ', 0.0, 0.0>'
  printf, lun, '  look_at <' + strjoin(strtrim(self.look_at, 2), ',') + '>'
  printf, lun, '  angle ' + strtrim(self.angle, 2)
  if (self.aperture gt 0.0) then begin
    printf, lun, '  focal_point <' + strjoin(strtrim(self.focalPoint, 2), ', ') + '>'
    printf, lun, '  aperture ' + strtrim(self.aperture, 2)
    printf, lun, '  blur_samples ' + strtrim(self.blurSamples, 2)        
  endif
  printf, lun, '}'
  
  free_lun, lun
end


;+
; Write the .ini file.
; 
; :Private:
;-
pro visgrpovray::_writeIni
  compile_opt strictarr
  
  filename = self.filePrefix + '.ini'
  openw, lun, filename, /get_lun
  
  printf, lun, 'Input_File_Name=' + file_basename(self.filePrefix) + '.pov'
  printf, lun, format='(%"+W%d +H%d")', self.dimensions
  
  free_lun, lun
end


;+
; Traverse the object graphics hierarchy rooted from the given node.
;
; :Private:
; 
; :Params:
;    tree : in, required, type=object
;       any node (including children) in the object graphics hierarchy to 
;       process
;    prefix : in, required, type=string
;       filename prefix to add to generated files
;
; :Keywords:
;    includes : in, out, required, type=strarr
;       list of files to include in the .pov file; undefined to represent the
;       empty list
;-
pro visgrpovray::_traverse, tree, prefix, includes=includes
  compile_opt strictarr
  on_error, 2
  
  tree->getProperty, hide=hide
  if (hide) then return
  
  switch 1 of 
    ;obj_isa(tree, 'Orb'):
    obj_isa(tree, 'VISgrPOVRayGrid'):    
    obj_isa(tree, 'VISgrPOVRayLight'):
    obj_isa(tree, 'VISgrPOVRayPolygon'): 
    obj_isa(tree, 'VISgrPOVRayTubes'): begin
        self->_writePOVObject, tree, prefix, includes=includes
        break
      end
    
    obj_isa(tree, 'IDLgrScene'):
    obj_isa(tree, 'IDLgrView'):
    obj_isa(tree, 'IDLgrViewGroup'):
    obj_isa(tree, 'IDLgrModel'): begin
        tree->getProperty, name=name
        
        myName = name eq '' ? strlowcase(obj_class(tree)) : name
        for c = 0L, tree->count() - 1L do begin
          self->_traverse, tree->get(position=c), $
                           prefix + '_' + myName, $
                           includes=includes
        endfor
        
        if (obj_isa(tree, 'IDLgrView')) then begin
          self.nviews++
          tree->getProperty, viewplane_rect=vpr, zclip=zclip, eye=eye, $
                             color=color
          self.look_at = [vpr[0] + vpr[2] / 2., $
                          vpr[1] + vpr[3] / 2., $
                          (zclip[0] + zclip[1]) / 2.]
          self.location = [0., 0., eye]
          self.background = color
          self.angle = 2.0 * atan(vpr[2] / 2.0 / eye) * !radeg
        endif
        
        if (obj_isa(tree, 'VISgrPOVRayView')) then begin
          tree->getProperty, focal_point=focalPoint, aperture=aperture, $
                             blur_sample=blurSamples
          self.focalPoint = focalPoint
          self.aperture = aperture
          self.blurSamples = blurSamples
        endif
        
        break
      end
    
    obj_isa(tree, 'IDLgrPolygon'): begin
        self->_writePolygon, tree, prefix, includes=includes
        break
      end

    obj_isa(tree, 'IDLgrSurface'): begin
        self->_writeSurface, tree, prefix, includes=includes
        break
      end

    obj_isa(tree, 'IDLgrPolyline'): begin
        self->_writePolyline, tree, prefix, includes=includes
        break
      end

    obj_isa(tree, 'IDLgrLight'): begin
        self->_writeLight, tree, prefix, includes=includes
        break
      end
          
    obj_isa(tree, 'IDLgrText'): begin
        self->_writeText, tree, prefix, includes=includes
        break
      end
    
    ; POV-Ray can't handle these types
    obj_isa(tree, 'IDLgrImage'):
    obj_isa(tree, 'IDLgrAxis'):
    obj_isa(tree, 'IDLgrVolume'):
    obj_isa(tree, 'IDLgrContour'): break
    
    else: message, 'unknown atom type'
  endswitch
end


;+
; Write the object graphics rooted at the specified scene or view.
; 
; :Params:
;    tree : in, optional, type=object
;       scene or view object
;-
pro visgrpovray::draw, tree
  compile_opt strictarr
  on_error, 2
  
  ; if no tree argument, then use self.graphicsTree
  if (n_params() eq 0 && ~obj_valid(self.graphicsTree)) then begin
    message, 'GRAPHICS_TREE property must be set if no argument'
  endif
  
  ; if arg is present, it must be a valid object
  if (n_params() gt 0 && ~obj_valid(tree)) then message, 'invalid tree object'
  
  _tree = n_elements(tree) eq 0L ? self.graphicsTree : tree
                    
  ; traverse the object graphics hierarchy and write a .inc file for each
  ; graphics atom; the filename should use the "name" property of each item,
  ; if present
  self->_traverse, _tree, self.filePrefix, includes=includes
  
  ; write the .pov file  
  self->_writePov, _tree, includes=includes

  ; write the .ini file  
  self->_writeIni
end


;+
; Set properties.
;-
pro visgrpovray::setProperty, file_prefix=filePrefix, dimensions=dimensions
  compile_opt strictarr
  
  if (n_elements(filePrefix) gt 0) then self.filePrefix = filePrefix
  if (n_elements(dimensions) gt 0) then self.dimensions = dimensions  
end


;+
; Get properties.
;-
pro visgrpovray::getProperty, file_prefix=filePrefix, dimensions=dimensions
  compile_opt strictarr

  if (arg_present(filePrefix)) then filePrefix = self.filePrefix
  if (arg_present(dimensions)) then dimensions = self.dimensions  
end


;+
; Free resources.
;-
pro visgrpovray::cleanup
  compile_opt strictarr

  obj_destroy, self.graphicsTree
end


;+
; Create POV-Ray output destination for object graphics.
;
; :Returns:
;    1 for success, 0 for failure
; 
; :Keywords:
;    file_prefix : in, optional, type=string, default='idlgr'
;       prefix to add to all output files; final result will be::
;
;          file_prefix + '.png'
;
;    dimensions : in, optional, type=lonarr(2), default="[400, 400]"
;       default image size of the POV-Ray result
;    graphics_tree : in, optional, type=object
;       graphics tree to tree if none is provided to draw method
;-
function visgrpovray::init, file_prefix=filePrefix, dimensions=dimensions, $
                            graphics_tree=graphicsTree
  compile_opt strictarr
  
  if (~self->VISgrPOVRayObject::init()) then return, 0
  
  self.hasLight = 0B
  self.ambientIntensity = 0.0
  
  self.filePrefix = n_elements(filePrefix) eq 0 ? 'visgrpovray' : filePrefix
  self.dimensions = n_elements(dimensions) eq 0 ? [400, 400] : dimensions 
  self.graphicsTree = n_elements(graphicsTree) eq 0 ? obj_new() : graphicsTree
  
  dir = file_dirname(filePrefix)
  if (~file_test(dir)) then file_mkdir, dir
  
  return, 1
end


;+
; Define instance variables.
; 
; :Fields:
;    filePrefix
;       prefix for filename in output
;    dimensions
;       default size of output image
;    graphicsTree
;       graphics tree to tree if none is provided to draw method
;    hasLight
;       boolean indicating if the view has a light source in it (so that the
;       default light source is not needed)
;    ambientIntensity
;       intensity of the ambient light in the scene, 0.0 to 1.0
;    nviews
;       the number of views in the graphics hierarchy; right now only one view
;       is supported
;    location
;       location of the camera i.e. (0.0, 0.0, eye)
;    look_at
;       location the camera is pointed at in POV-Ray (IDL is always the origin)
;    background
;       background color of the scene
;    angle
;       angle of view of the camera
;    focalPoint
;       focus point of the camera to use to render a scene using focal blur
;    aperture
;       aperture of the camera to use to render a scene using focal blur
;    blurSamples
;       the number of rays to use to render a scene using focal blur
;-
pro visgrpovray__define
  compile_opt strictarr

  define = { VISgrPOVRay, inherits VISgrPOVRayObject, $
  
             ; properties of the destination
             filePrefix: '', $
             dimensions: lonarr(2), $
             graphicsTree: obj_new(), $
             
             ; properties of the scene
             hasLight: 0B, $
             ambientIntensity: 0.0, $             
             nviews: 0L, $
             
             ; properties of the view
             location: fltarr(3), $
             look_at: fltarr(3), $
             background: bytarr(3), $
             angle: 0.0, $
             focalPoint: fltarr(3), $
             aperture: 0.0, $
             blurSamples: 0L $
           }
end


; main-level example program of using the VISgrPOVRay class

view = obj_new('IDLgrView', name='view', color=[200, 200, 255])

model = obj_new('IDLgrModel', name='model')
view->add, model

cowFilename = filepath('cow10.sav', subdir=['examples', 'data'])
restore, cowFilename
colors = randomu(seed, n_elements(x))
vertcolors = rebin(reform(255 * round(colors), 1, n_elements(x)), 3, n_elements(x))

cow = obj_new('IDLgrPolygon', x, y, z, polygons=polylist, $
              color=[150, 100, 20], shading=1, $
              vert_colors=vertcolors, $;clip_planes=[0, 0, 1, 0], $
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

light = obj_new('IDLgrLight', type=2, location=[0, 5, 5], intensity=1.0)
model->add, light
alight = obj_new('IDLgrLight', type=0, intensity=1.0)
model->add, alight

textModel = obj_new('IDLgrModel')
view->add, textModel

font = obj_new('IDLgrFont', size=12)
text = obj_new('IDLgrText', ['POV-Ray interface to IDL', 'mgalloy'], $
                font=font, $
                locations=[[-0.75, 0.5], [0.5, 0.5]])
textModel->add, text

dims = [640, 480]

win = obj_new('IDLgrWindow', dimensions=dims, title='Object graphics Cow')
win->setProperty, graphics_tree=view
win->draw

pov = obj_new('VISgrPOVRay', file_prefix='cow-output/cow', dimensions=dims)
pov->draw, view

obj_destroy, [pov, font]

; create an image of the scene with:
;
;    $ povray +P +A cow.ini

cowImage = vis_povray('cow-output/cow')
vis_image, cowImage, /new_window, title='POV-Ray cow image'

end

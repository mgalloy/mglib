; docformat = 'rst'

;+
; A `MGgrPOVRayPolygon` represents a polygon with POV-Ray specific attributes
; like the finish attribute class.
;
; :Categories:
;    object graphics
;
; :Properties:
;    finish
;       `IDLgrPOVRayFinish` attribute object for the polygon
;    _extra
;       properties of `IDLgrPolygon`
;    _ref_extra
;       properties of `IDLgrPolygon`
;-


;+
; Write the POV-Ray description of the polygon.
;
; :Private:
;
; :Params:
;    lun : in, required, type=long
;       logical unit number to write to
;-
pro mggrpovraypolygon::write, lun
  compile_opt strictarr

  self->getProperty, data=vertices, normals=normals, polygons=polygons, $
                     color=color, alpha_channel=alphaChannel, shading=shading, $
                     texture_map=textureMap, texture_coord=textureCoord, $
                     vert_colors=vertcolors, $
                     xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc, $
                     clip_planes=clipPlanes, $
                     shininess=shininess, ambient=ambient, diffuse=diffuse, $
                     specular=specular, emission=emission

  hasVertColors = vertcolors[0] ne -1L
  hasTextureMap = obj_valid(textureMap)

  szVertices = size(vertices, /structure)
  nVertices = szVertices.dimensions[1]

  if (polygons[0] eq -1L) then polygons = [nVertices, lindgen(nVertices)]

  ntriangles = mesh_validate(vertices, polygons)

  if (self.finish->hasName()) then begin
    printf, lun, '#include "metals.inc"'
    printf, lun, '#include "finish.inc"'
    printf, lun, '#include "textures.inc"'
    printf, lun
  endif

  printf, lun, 'mesh2 {'

  self->_writeVertices, lun, vertices, name='vertex_vectors'

  case shading of
    0:
    1: self->_writeVertices, lun, compute_mesh_normals(vertices, polygons), $
                             name='normal_vectors'
    else: message, 'unknown shading method'
  endcase

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

  ; TODO: this is not quite right
  ; write texture_list if polygon has a texture_map
  if (hasTextureMap) then begin
    textureMap->getProperty, data=im
    tSize = size(vertices, /structure)
    imSize = size(im, /structure)
    printf, lun
    printf, lun, '  texture_list {'
    printf, lun, '    ' + strtrim(tSize.dimensions[1], 2) + ','
    pre = '    texture { pigment { '
    post = ' }}'
    for t = 0L, tSize.dimensions[1] - 1L do begin
      coords = reform(textureCoord[*, t]) * (imSize.dimensions[1:2] - 1L)
      color = im[*, coords[0], coords[1]]
      printf, lun, pre + self->_getRGB(color, alpha_channel=alphaChannel) + post
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

  self->_writeTransform, lun, self->getCTM()

  ; TODO: use emission for radiosity

  printf, lun
  printf, lun, '  pigment { ' + self->_getRgb(color, alpha_channel=alphaChannel) + ' }'

  if (obj_valid(self.finish)) then begin
    self.finish->write, lun
  endif else begin
    printf, lun, '  finish {'
    printf, lun, '    phong ' + strtrim(shininess / 128.0, 2)
    printf, lun, '    phong_size ' + strtrim(shininess, 2)
    printf, lun, '  }'
  endelse

  if (self.noShadow) then printf, lun, '  no_shadow'

  printf, lun, '}'
end


;+
; Get properties.
;-
pro mggrpovraypolygon::getProperty, finish=finish, no_shadow=noShadow, $
                                    _ref_extra=e
  compile_opt strictarr

  if (arg_present(finish)) then finish = self.finish
  if (arg_present(noShadow)) then noShadow = self.noShadow

  if (n_elements(e) gt 0) then begin
    self->idlgrpolygon::getproperty, _strict_extra=e
  endif
end


;+
; Set properties.
;-
pro mggrpovraypolygon::setProperty, finish=finish, no_shadow=noShadow, $
                                    _ref_extra=e
  compile_opt strictarr

  if (n_elements(finish) gt 0L) then self.finish = finish
  if (n_elements(noShadow) gt 0L) then self.noShadow = noShadow

  if (n_elements(e) gt 0) then begin
    self->idlgrpolygon::setproperty, _strict_extra=e
  endif
end


;+
; Free resources.
;-
pro mggrpovraypolygon::cleanup
  compile_opt strictarr

  self->idlgrpolygon::cleanup
end


;+
; Create `MGgrPOVRayPolygon` object.
;
; :Returns:
;    1 for success, 0 for failure
;
; :Params:
;    x : in, optional, type=fltarr(n)
;       x-coordinates of vertices of the polygon
;    y : in, optional, type=fltarr(n)
;       y-coordinates of vertices of the polygon
;    z : in, optional, type=fltarr(n)
;       z-coordinates of vertices of the polygon
;-
function mggrpovraypolygon::init, x, y, z, $
                                  finish=finish, no_shadow=noShadow, $
                                  _extra=e
  compile_opt strictarr

  if (~self->idlgrpolygon::init(x, y, z, _extra=e)) then return, 0
  if (~self->MGgrPOVRayObject::init()) then return, 0

  if (obj_valid(finish)) then self.finish = finish
  self.noShadow = keyword_set(noShadow)

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    finish
;       finish attribute object
;-
pro mggrpovraypolygon__define
  compile_opt strictarr

  define = { MGgrPOVRayPolygon, $
             inherits IDLgrPolygon, inherits MGgrPOVRayObject, $
             finish: obj_new(), $
             noShadow: 0B $
           }
end
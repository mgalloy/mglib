; docformat = 'rst'

;+
; Class representing an ellipse.
;
; :Categories:
;    object graphics
;
; :Examples:
;    See the main-level example program at the end of this file::
;
;       IDL> .run visgrellipsoid__define
;
;    This should produce:
;
;    .. image:: ellipsoid.png
;
; :Properties:
;    pos : type=fltarr(3)
;       A three-element vector, [x, y, z], specifying the position of the 
;       center of the ellipsoid, measured in data units
;    radius : type=fltarr(3)
;       a floating point number representing the radius of the ellipsoid 
;       (measured in data units) in the x-, y-, and z-directions
;    density : type=float
;       A floating point number representing the density at which the vertices 
;       should be generated along the surface of the orb
;    parent : type=object
;       not used, included only for compatibility to Orb class
;    pobj : type=object
;       underlying polygon object
;    tex_coords : type=boolean 
;       set this keyword to a nonzero value if texture map coordinates are to 
;       be generated for the orb
;    _extra : type=keywords
;       keywords to IDLgrModel::setProperty or IDLgrPolygon::setProperty
;-

;+
; Set properties of the ellipsoid.
;-
pro visgrellipsoid::setProperty, pos=pos, radius=radius, density=density, $
                                 parent=parent, _extra=e
  compile_opt strictarr
  on_error, 2

  ; pass along extraneous keywords to the superclass and/or to the
  ; polygon used to represent the orb
  self->IDLgrModel::setProperty, _extra=e
  self.polygon->setProperty, _extra=e

  self.pos = n_elements(pos) eq 3 ? pos : self.pos

  case n_elements(radius) of
    0 :
    1 : self.radius = fltarr(3) + radius
    3 : self.radius = radius
    else : message, 'RADIUS must be 1- or 3-elements array'
  endcase

  self.density = n_elements(density) eq 1 ? density : self.density
  
  ; rebuild the polygon according to keyword settings
  self->_buildPoly
end


;+
; Get properties of the ellipsoid.
;-
pro visgrellipsoid::getProperty, pos=pos, radius=radius, density=density, $
                                 pobj=pobj, _ref_extra=re
  compile_opt strictarr

  ; retrieve extra properties from polygon first, then model
  ; so that the model settings (for common keywords) will prevail
  self.polygon->getProperty, _extra=re
  self->IDLgrModel::getProperty, _extra=re
  
  if (arg_present(pos)) then pos = self.pos
  if (arg_present(radius)) then radius = self.radius 
  if (arg_present(density)) then density = self.density 
  if (arg_present(pobj)) then pobj = self.polygon
end


;+
; Prints position, radius, and density of the ellipsoid for debugging 
; purposes.
;-
pro visgrellipsoid::print
  compile_opt strictarr

  print, self.pos 
  print, self.radius
  print, self.density
end


;+
; Sets the vertex and connectivity arrays for the polygon used to
; represent the orb.
;-
pro visgrellipsoid::_buildPoly
  compile_opt strictarr

  ; number of rows and columns of vertices is based upon the density property
  nrows = long(20. * self.density)
  ncols = long(20. * self.density)
  if (nrows lt 2) then nrows = 2
  if (ncols lt 2) then ncols = 2

  ; create the vertex list and the connectivity array.
  nverts = nrows * ncols + 2
  nconn = (ncols * (nrows - 1) * 5) + (2 * ncols * 4)
  conn = lonarr(ncols * (nrows - 1) * 5 + 2 * ncols * 4)
  verts = fltarr(3, nverts)

  if (self.texture) then tex = fltarr(2, nverts)

  ; fill in the vertices.
  i = 0L
  j = 0L
  k = 0L
  tzinc = !pi / float(nrows + 1)
  tz = !pi / 2.0 - tzinc 
  for k = 0, nrows - 1 do begin
    t = 0
    if (self.texture) then begin
      tinc = 2.0 * !pi / float(ncols - 1)
    endif else begin
      tinc = 2.0 * !pi / float(ncols)
    endelse
    for j = 0, ncols - 1 do begin
      verts[0, i] = self.radius[0] * cos(tz) * cos(t) + self.pos[0]
      verts[1, i] = self.radius[1] * cos(tz) * sin(t) + self.pos[1]
      verts[2, i] = self.radius[2] * sin(tz)          + self.pos[2]
      
      if (self.texture) then begin
        tex[0, i] = t / (2.0 * !pi)
        tex[1, i] = (tz + (!pi / 2.0)) / !pi
      endif
      
      t += tinc
      ++i
    endfor
    tz -= tzinc
  endfor

  top = i
  verts[0, i] = self.pos[0]
  verts[1, i] = self.pos[1]
  verts[2, i] = self.radius[2] + self.pos[2]
  ++i
  bot = i
  verts[0, i] = self.pos[0]
  verts[1, i] = self.pos[1]
  verts[2, i] = - self.radius[2] + self.pos[2]
  
  if (self.texture) then begin
    tex[0, i] = 0.5
    tex[1, i] = 0.0
    tex[0, i - 1] = 0.5
    tex[1, i - 1] = 1.0
  endif
  
  ; fill in the connectivity array.
  i = 0
  for k = 0, nrows - 2 do begin
    for j = 0, ncols - 1 do begin
      conn[i] = 4
      
      conn[i + 4] = k * ncols + j
      
      w = k * ncols + j + 1L
      if (j eq (ncols-1)) then w = k * ncols
      conn[i + 3] = w
      
      w = k * ncols + j + 1L + ncols
      if (j eq (ncols - 1)) then w = k * ncols + ncols
      conn[i + 2] = w
      
      conn[i + 1] = k * ncols + j + ncols
      
      i += 5L
      if ((self.texture) and (j eq (ncols - 1))) then i -= 5L
    endfor
  endfor

  for j = 0, ncols - 1 do begin
    conn[i] = 3
    conn[i + 3] = top
    conn[i + 2] = j + 1L
    if (j eq (ncols - 1)) then conn[i + 2] = 0
    conn[i + 1] = j
    i += 4L
    if ((self.texture) and (j eq (ncols - 1))) then i -= 4L
  endfor

  for j=0, ncols - 1 do begin
    conn[i] = 3
    conn[i + 3] = bot
    conn[i + 2] = j + (nrows - 1L) * ncols
    conn[i + 1] = j + (nrows - 1L) * ncols + 1L
    if (j eq (ncols - 1)) then conn[i + 1] = (nrows - 1L) * ncols
    i += 4L
    if ((self.texture) and (j eq (ncols - 1))) then i -= 4L
  endfor
  
  self.polygon->setProperty, data=verts, polygons=conn
  
  if (self.texture) then self.polygon->setProperty, texture_coord=tex
end


;+
; Free resources.
;-
pro visgrellipsoid::cleanup
  compile_opt strictarr

  ; cleanup the polygon object used to represent the orb
  obj_destroy, self.polygon
  
  ; cleanup the superclass
  self->IDLgrModel::cleanup
end


;+
; Initialize ellipsoid.
;
; :Returns: 
;    1 for success, 0 for failure
;-
function visgrellipsoid::init, pos=pos, radius=radius, density=density, $
                               tex_coords=texCoords, _extra=e
  compile_opt strictarr
  on_error, 2

  if (self->IDLgrModel::init(_extra=e) ne 1) then return, 0

  self.pos = n_elements(pos) eq 3 ? pos : [0.0, 0.0, 0.0]

  case n_elements(radius) of
    0 : self.radius = fltarr(3) + 1.0
    1 : self.radius = fltarr(3) + radius
    3 : self.radius = radius
    else : message, 'RADIUS must be 1- or 3-elements array'
  endcase

  self.density = n_elements(density) eq 1 ? density : 1.0
  self.texture = n_elements(texCoords) eq 1 ? keyword_set(texCoords) : 0
  
  ; initialize the polygon object that will be used to represent the orb
  self.polygon = obj_new('IDLgrPolygon', shading=1, /reject, _extra=e)
  
  self->add, self.polygon
  
  ; build the polygon vertices and connectivity based on its properties
  self->_buildPoly
  
  return, 1
end


;+
; Define member variables.
;
; :Fields:
;    pos 
;       position of the center of the ellipsoid
;    radius 
;       floating point numbers representing the radius of the ellipsoid 
;       (measured in data units) in the x-, y-, and z-directions
;    density 
;       value representing the density at which the vertices should be 
;       generated along the surface of the orb
;    texture 
;       boolean for whether texture coordinates are needed for the 
;       ellipsoid
;    polygon 
;       IDLgrPolygon object containing verts and conn of the ellipsoid
;-
pro visgrellipsoid__define
    struct = { VISgrEllipsoid, $
               inherits IDLgrModel, $
               pos: [0.0, 0.0, 0.0], $
               radius: fltarr(3), $
               density: 0.0, $
               texture: 0, $
               polygon: obj_new() $
             }
end


; main-level example program

view = obj_new('IDLgrView', color=[0, 0, 0])

model = obj_new('IDLgrModel')
view->add, model

ellipsoid = obj_new('VISgrEllipsoid', radius=[0.3, 0.3, 0.6], $
                    color=[200, 200, 0], shading=0)
model->add, ellipsoid

light = obj_new('IDLgrLight', type=2, location=[-1, 1, 1])
model->add, light
ambientLight = obj_new('IDLgrLight', intensity=0.25)
model->add, ambientLight

model->rotate, [0, 1, 0], 30
model->rotate, [1, 0, 0], 30

win = obj_new('IDLgrWindow', dimensions=[400, 400], graphics_tree=view)
win->draw, view

end




; docformat = 'rst'

;+
; Destination class for x3d graphics suitable for display on a web page by
; a modern browser.
;
; :Properties:
;    dimensions
;       dimensions of output graphic
;    filename
;       filename to send output to
;    graphics_tree
;       graphics hierarchy to draw by default
;    indent
;       string to indent lines in the output by; default is to use two spaces
;-


;+
; Draw the given scene and send its output to the file specified by the
; `FILENAME` property.
;
; :Params:
;    tree : in, optional, type=objref
;       object graphics hierarchy to draw; optional, but then `GRAPHICS_TREE`
;       property must be set
;
; :Keywords:
;    full_html : in, optional, type=boolean
;       set to write an entire HTML file instead of just the w3dom content
;-
pro mggrx3d::draw, tree, full_html=full_html
  compile_opt strictarr
  on_error, 2
  
  ; if no tree argument, then use self.graphicsTree
  if (n_params() eq 0 && ~obj_valid(self.graphicsTree)) then begin
    message, 'GRAPHICS_TREE property must be set if no argument'
  endif
  
  ; if arg is present, it must be a valid object
  if (n_params() gt 0 && ~obj_valid(tree)) then message, 'invalid tree object'
  
  _tree = n_elements(tree) eq 0L ? self.graphicsTree : tree
  
  openw, lun, self.filename, /get_lun
  self.lun = lun

  _indent = keyword_set(full_html) ? '    ' : ''
  if (keyword_set(full_html)) then self->_writeHTMLHeader

  scene_format = '(%"%s<x3d width=\"%dpx\" height=\"%dpx\">")'
  printf, self.lun, _indent, self.dimensions, format=scene_format
  
  self->_traverse, _tree, indent=_indent + self.indent
  
  printf, self.lun, _indent, format='(%"%s</x3d>")'

  if (keyword_set(full_html)) then self->_writeHTMLFooter
  
  free_lun, self.lun
  self.lun = -1L
end


;+
; Write the HTML header if `FULL_HTML` is set on the `draw` method.
;
; :Private:
;-
pro mggrx3d::_writeHTMLHeader
  compile_opt strictarr

  printf, self.lun, '<html>'
  printf, self.lun, '  <head>'
  printf, self.lun, '    <link rel="stylesheet" type="text/css"'
  printf, self.lun, '          href="http://www.x3dom.org/x3dom/release/x3dom.css">'
  printf, self.lun, '    </link>'
  printf, self.lun, '    <script type="text/javascript"'
  printf, self.lun, '            src="http://www.x3dom.org/x3dom/release/x3dom.js">'
  printf, self.lun, '    </script'
  printf, self.lun, '  </head>'
  printf, self.lun, '  <body>'      
end


;+
; Write the HTML footer if `FULL_HTML` is set on the `draw` method.
;
; :Private:
;-
pro mggrx3d::_writeHTMLFooter
  compile_opt strictarr

  printf, self.lun, '  </body>'
  printf, self.lun, '</html>'
end


;+
; Traverse the given object graphics hierarchy and write the output to the 
; file specified by the `FILENAME` property.
;
; :Private:
;
; :Params:
;    tree : in, required, type=objref
;       object graphics hierarchy to draw
;
; :Keywords:
;    indent : in, optional, type=string, default=''
;       indent string
;-
pro mggrx3d::_traverse, tree, indent=indent
  compile_opt strictarr
  on_error, 2
  
  _indent = n_elements(indent) eq 0L ? self.indent : indent
  format = '(%"unsupported class in graphics tree: %s")'
  
  case 1 of
    obj_isa(tree, 'IDLgrView'): self->_writeView, tree, indent=_indent
    obj_isa(tree, 'IDLgrModel'): self->_writeModel, tree, indent=_indent
    obj_isa(tree, 'IDLgrPolygon'): self->_writePolygon, tree, indent=_indent
    obj_isa(tree, 'IDLgrLight'):
    else: message, string(obj_class(tree), format=format)
  endcase
end


;+
; Write the x3d scene node and its children that represent the object graphics
; view.
; 
; :Private:
;
; :Params:
;    tree : in, required, type=objref
;       object graphics hierarchy to draw
;
; :Keywords:
;    indent : in, required, type=string
;       indent string
;-
pro mggrx3d::_writeView, tree, indent=indent
  compile_opt strictarr

  tree->getProperty, color=color, viewplane_rect=vpr, eye=eye
  
  printf, self.lun, indent, format='(%"%s<scene>")'

  printf, self.lun, indent, self.indent, eye, $
          format='(%"%s%s<viewpoint position=''0 0 %f''></viewpoint>")'

  printf, self.lun, indent, self.indent, self->_convertColor(color), $
          format='(%"%s%s<background skycolor=''%s''></background>")'

  ; write children of tree
  for c = 0L, tree->count() - 1L do begin
    self->_traverse, tree->get(position=c), indent=indent + self.indent
  endfor

  printf, self.lun, indent, format='(%"%s</scene>")'
end


;+
; Write the x3d matrix transform node and children that represent an object
; graphics model.
;
; :Private:
;
; :Params:
;    tree : in, required, type=objref
;       object graphics hierarchy to draw
;
; :Keywords:
;    indent : in, required, type=string
;       indent string
;-
pro mggrx3d::_writeModel, tree, indent=indent
  compile_opt strictarr

  tree->getProperty, transform=transform
  matrix = strjoin(strtrim(reform(transform, 16), 2), ' ')
  printf, self.lun, indent, matrix, $
          format='(%"%s<matrixtransform matrix=''%s''>")'

  ; write children of tree
  for c = 0L, tree->count() - 1L do begin
    self->_traverse, tree->get(position=c), indent=indent + self.indent
  endfor

  printf, self.lun, indent, format='(%"%s</matrixtransform>")'  
end


;+
; Write output for a `IDLgrPolygon` object.
;
; :Private:
;
; :Params:
;    tree : in, required, type=objref
;       object graphics hierarchy to draw
;
; :Keywords:
;    indent : in, required, type=string
;       indent string
;-
pro mggrx3d::_writePolygon, tree, indent=indent
  compile_opt strictarr

  tree->getProperty, data=pts, polygons=polygons, color=color
  ;normals = compute_mesh_normals(vertices, polygons)

  coord_pts = strjoin(strtrim(reform(pts, n_elements(pts)), 2), ' ')
  coord_index = strjoin(strtrim(self->_convertPolygons(polygons), 2), ' ')

  normal_vector = ''
  tex_pts = ''
  normal_index = ''
  tex_index = ''
  
  printf, self.lun, indent, format='(%"%s<shape>")'
  
  ; write appearance
  printf, self.lun, indent, self.indent, format='(%"%s%s<appearance>")'
  ; TODO: fill in material, imagetexture
  printf, self.lun, indent, self.indent, self->_convertColor(color), $
          format='(%"%s%s<material diffusecolor=''%s''>")'
  printf, self.lun, indent, self.indent, format='(%"%s%s</material>")'
  printf, self.lun, indent, self.indent, format='(%"%s%s</appearance>")'
  
  ; write polygons

  printf, self.lun, indent, self.indent, coord_index, $   ; normal_index, tex_index, $
          format='(%"%s%s<indexedfaceset coordindex=''%s''>")'  ; normalindex=''%s'' texcoordindex=''%s''
  printf, self.lun, indent, self.indent, self.indent, coord_pts, $
          format='(%"%s%s%s<coordinate point=''%s''/>")'
  ; printf, self.lun, indent, self.indent, self.indent, normal_vector, $
  ;         format='(%"%s%s%s<normal vector=''%s''/>")'
  ; printf, self.lun, indent, self.indent, self.indent, tex_pts, $
  ;         format='(%"%s%s%s<texturecoordinate point=''%s''/>")'
  printf, self.lun, indent, self.indent, format='(%"%s%s</indexedfaceset>")'
  
  printf, self.lun, indent, format='(%"%s</shape>")'
  
end


;+
; Convert between IDL scheme and x3d scheme for specifying a color.
;
; :Private:
;
; :Returns:
;    string
;
; :Params:
;    rgb : in, required, type=bytarr(3)
;       connectivity list specified in IDL's scheme 
;-
function mggrx3d::_convertColor, rgb
  compile_opt strictarr
  
  return, strjoin(strtrim(float(rgb) / 255., 2), ' ')
end


;+
; Convert between IDL scheme and x3d scheme for connectivity list for a polygon.
;
; :Private:
;
; :Returns:
;    `lonarr(n)`
;
; :Params:
;    conn : in, required, type=lonarr(n)
;       connectivity list specified in IDL's scheme 
;-
function mggrx3d::_convertPolygons, conn
  compile_opt strictarr
  
  n = n_elements(conn)
  result = conn
  
  pos = 0
  while (pos lt n && conn[pos] gt 0L) do begin
    nverts = conn[pos]
    result[pos] = conn[pos+1:pos + nverts]
    result[pos + nverts] = -1L
    pos += nverts + 1L
  endwhile
  
  return, result
end


;+
; Retrieve properties.
;-
pro mggrx3d::getProperty, dimensions=dimensions, $
                          filename=filename, $
                          graphics_tree=graphics_tree, $
                          indent=indent
  compile_opt strictarr
  
  dimensions = self.dimensions
  filename = self.filename
  graphics_tree = self.graphics_tree
end


;+
; Set properties.
;-
pro mggrx3d::setProperty, dimensions=dimensions, $
                          filename=filename, $
                          graphics_tree=graphics_tree, $
                          indent=indent
  compile_opt strictarr
  
  if (n_elements(dimensions) gt 0L) then self.dimensions = dimensions
  if (n_elements(filename) gt 0L) then self.filename = filename
  if (n_elements(graphics_tree) gt 0L) then self.graphics_tree = graphics_tree
  if (n_elements(indent) gt 0L) then self.indent = indent
end


;+
; Free resources.
;-
pro mggrx3d::cleanup
  compile_opt strictarr
  
  if (obj_valid(self.graphics_tree)) then obj_destroy, self.graphics_tree
end


;+
; Retrieve properties.
;
; :Returns:
;    1 if successfully initialized, 0 if failed
;
; :Keywords:
;    _extra : in, optional, type=keywords
;       properties
;-
function mggrx3d::init, _extra=e
  compile_opt strictarr

  ; set default properties
  self.indent = '  '
  self.dimensions = [400L, 400L]
  self.lun = -1L
  
  self->setProperty, _extra=e
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    dimensions
;       dimensions of output graphic
;    filename
;       filename to send output to
;    graphics_tree
;       graphics hierarchy to draw by default
;    indent
;       string to indent lines in the output by
;    lun
;       logical unit number to write to
;-
pro mggrx3d__define
  compile_opt strictarr
  
  define = { MGgrX3D, $
             dimensions: lonarr(2), $
             filename: '', $
             graphics_tree: obj_new(), $
             indent: '', $
             lun: 0L $
           }
end


; main-level example program

view = obj_new('IDLgrView', name='view', color=[200, 200, 255])

model = obj_new('IDLgrModel', name='model')
view->add, model

cowFilename = filepath('cow10.sav', subdir=['examples', 'data'])
restore, cowFilename

cow = obj_new('IDLgrPolygon', x, y, z, polygons=polylist, $
              color=[150, 100, 20])
model->add, cow

xmin = min(x, max=xmax)
xrange = xmax - xmin
ymin = min(y, max=ymax)
yrange = ymax - ymin
zmin = min(z, max=zmax)
zrange = zmax - zmin

light = obj_new('IDLgrLight', type=2, location=[-1., 1., 1.])
model->add, light

model->rotate, [0, 1, 0], -30
model->rotate, [1, 0, 0], 30

; render

dims = [640, 480]

win = obj_new('IDLgrWindow', dimensions=dims, title='Object graphics Cow')
win->setProperty, graphics_tree=view
win->draw

x3d = obj_new('MGgrX3D', filename='cow.html', dimensions=dims)
x3d->draw, view, /full_html

obj_destroy, x3d

end
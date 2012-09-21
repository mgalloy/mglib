; docformat = 'rst'

;+
; Object graphics destination for producing Scalable Vector Graphics (SVG) 
; files.
;
; Because SVG is inherently 2-dimensional, it only supports 2-dimensional
; object graphics hierarchies. Only objects of the following classes are 
; supported::
;
;    IDLgrScene                          svg element
;    IDLgrViewGroup                      svg element
;    IDLgrView                           svg element
;    IDLgrModel                          g element
;    IDLgrText (and IDLgrFont)           text element
;    IDLgrPolygon (and IDLgrPattern)     path element (TODO: handle patterns)
;    IDLgrPolyline (and IDLgrSymbol)     path element (TODO: handle symbols)
;    IDLgrPlot                           path element
;    IDLgrAxis
;    IDLgrImage                          image element
;
; :Examples:
;    Run the main-level program at the end of this file to see an example::
;
;       IDL> .run visgrsvg__define
;
;    This should produce the following:
;
;    .. embed:: triangle.svg
; 
; :Properties:
;    filename
;       filename of file to write to
;    graphics_tree
;       default picture to draw
;    dimensions
;       dimensions of the drawing canvas in units specified by the EM, EX, PX, 
;       PT, PC, CM, MM, INCHES, PERCENTAGE property at the same time as the 
;       DIMENSIONS property is set; if no dimensions are specified, the canvas 
;       is scaled to fill the available area
;-


;+
; Return a valid SVG specification for a color.
;
; :Returns:
;    string
;
; :Params:
;    color : in, required, type=bytarr(3)
;       color to convert
;-
function visgrsvg::_getRgb, color
  compile_opt strictarr
  
  return, string(color, '(%"rgb(%d, %d, %d)")')
end


;+
; Returns the VIEWPLANE_RECT for the view that contains the item.
;
; :Returns:
;    fltarr(4) or -1L
;
; :Params:
;    tree : in, required, type=object
;       object in the object graphics hierarchy
;-
function visgrsvg::_getVpr, tree, dimensions=dims, dimension_units=dimUnits
  compile_opt strictarr

  case 1 of
    obj_isa(tree, 'IDLgrView'): begin
        tree->getProperty, viewplane_rect=vpr, dimensions=dims, units=units
        if (array_equal(dims, [0., 0.])) then begin
          dims = [1., 1.]
          units = 3
        endif
        
        case units of
          0: dimUnits = 'px'
          1: dimUnits = 'in'
          2: dimUnits = 'cm'
          3: begin
              dims *= 100.
              dimUnits = '%'
            end
        endcase
        return, vpr
      end
    obj_isa(tree, 'IDLgrViewGroup'): return, -1L
    obj_isa(tree, 'IDLgrScene'): return, -1L
    else: begin
        tree->getProperty, parent=parent
        return, obj_valid(parent) ? self->_getVpr(parent, dimensions=dims, dimension_units=dimUnits) : -1L
      end
  endcase
end


function visgrsvg::_convertUnits, x, xUnits, outUnits
  compile_opt strictarr
  on_error, 2
  
  ; convert to user coordinates (or pixel coordinates)
  case xUnits of
    'em': message, 'not suppored'
    'ex': message, 'not suppored'
    '%' : message, 'not suppored'
    'pt': _x = x * 1.25
    'pc': _x = x * 15.
    'mm': _x = x * 3.543307
    'cm': _x = x * 35.43307
    'in': _x = x * 90.
    ''  : _x = x * 1.
    'px': _x = x * 1.
  endcase
  
  ; convert to desired output coordinates
  case outUnits of
    'em': message, 'not suppored'
    'ex': message, 'not suppored'
    '%' : message, 'not suppored'
    'pt': return, _x / 1.25
    'pc': return, _x / 15.
    'mm': return, _x / 3.543307
    'cm': return, _x / 35.43307
    'in': return, _x / 90.
    ''  : return, _x / 1.
    'px': return, _x / 1.
  endcase  
end


function visgrsvg::_transformCoords, data, tree=tree
  compile_opt strictarr
  
  vpr = self->_getVpr(tree)
  vpr *= self.textMultiplier

  result = data
  if (size(result, /n_dimensions) eq 1L) then begin
    result = reform(result, n_elements(result), 1)
  endif

  tree->getProperty, xcoord_conv=xc, ycoord_conv=yc
  result[0, *] = xc[0] + xc[1] * result[0, *]
  result[1, *] = yc[0] + yc[1] * result[1, *]

  result = result * self.textMultiplier

  result[1, *] = vpr[3] + 2. * vpr[1] - result[1, *]
  
  return, result
end


;+
; Handle IDLgrScene objects.
;
; :Params:
;    scene : in, required, type=object
;       IDLgrScene object graphics element
;
; :Keywords:
;    lun : in, required, type=long
;       logical unit number of file to write output to
;    indent : in, required, type=string
;       string to prefix each line of output by
;-
pro visgrsvg::_handleScene, scene, lun=lun, indent=indent
  compile_opt strictarr
  
  ; TODO: implement
end


;+
; Handle IDLgrViewGroup objects.
;
; :Params:
;    viewgroup : in, required, type=object
;       IDLgrViewGroup object graphics element
;
; :Keywords:
;    lun : in, required, type=long
;       logical unit number of file to write output to
;    indent : in, required, type=string
;       string to prefix each line of output by
;-
pro visgrsvg::_handleViewgroup, viewgroup, lun=lun, indent=indent
  compile_opt strictarr

  ; TODO: implement
end


;+
; Handle IDLgrView objects.
;
; :Params:
;    view : in, required, type=object
;       IDLgrView object graphics element
;
; :Keywords:
;    lun : in, required, type=long
;       logical unit number of file to write output to
;    indent : in, required, type=string
;       string to prefix each line of output by
;-
pro visgrsvg::_handleView, view, lun=lun, indent=indent
  compile_opt strictarr

  view->getProperty, viewplane_rect=vpr
  self.textMultiplier = 200. / (vpr[2] < vpr[3])
  vpr *= self.textMultiplier
  viewBox = strjoin(strtrim(vpr, 2), ' ')
  
  if (array_equal(self.dimensions, [0., 0.])) then begin
    dims = ''
  endif else begin
    dims = strtrim(self.dimensions, 2) + self.dimensionUnits
    dims = string(dims, '(%"width=\"%s\" height=\"%s\"")')
  endelse
  
  format = '(%"<svg version=\"1.1\" ' $
             + 'xmlns=\"http://www.w3.org/2000/svg\" ' $
             + 'xmlns:xlink=\"http://www.w3.org/1999/xlink\" ' $
             + '%s viewBox=\"%s\">")'
  s = string(dims, viewBox, format=format)
  printf, lun, indent + s
  for c = 0L, view->count() - 1L do begin
    self->_traverse, view->get(position=c), lun=lun, indent=indent + '    '
  endfor    
  printf, lun, indent + '</svg>'
end


;+
; Handle IDLgrModel objects.
;
; :Params:
;    model : in, required, type=object
;       IDLgrModel object graphics element
;
; :Keywords:
;    lun : in, required, type=long
;       logical unit number of file to write output to
;    indent : in, required, type=string
;       string to prefix each line of output by
;-
pro visgrsvg::_handleModel, model, lun=lun, indent=indent
  compile_opt strictarr

  vpr = self->_getVpr(model)
  
  model->getProperty, transform=transform

  printf, lun, indent, (2. * vpr[1] + vpr[3]) * self.textMultiplier, $
          format='(%"%s<g transform=\"translate(0, %f) scale(1, -1)\">")'
  format = '(%"  <g transform=\"matrix(%f %f %f %f %f %f)\">")'
  s = string(transform[0, 0], transform[0, 1], $
             transform[1, 0], transform[1, 1], $
             self.textMultiplier * transform[3, 0], self.textMultiplier * transform[3, 1], $
             format=format)
  printf, lun, indent + s
  printf, lun, indent, (- 2. * vpr[1] - vpr[3]) * self.textMultiplier, $
          format='(%"%s    <g transform=\"scale(1, -1) translate(0, %f)\">")'
  for c = 0L, model->count() - 1L do begin
    self->_traverse, model->get(position=c), lun=lun, indent=indent + '      '
  endfor    
  printf, lun, indent + '    </g>'  
  printf, lun, indent + '  </g>'  
  printf, lun, indent + '</g>'  
end


;+
; Handle IDLgrPolyline objects.
;
; :Params:
;    polyline : in, required, type=object
;       IDLgrPolyline object graphics element
;
; :Keywords:
;    lun : in, required, type=long
;       logical unit number of file to write output to
;    indent : in, required, type=string
;       string to prefix each line of output by
;-
pro visgrsvg::_handlePolyline, polyline, lun=lun, indent=indent
  compile_opt strictarr
  on_error, 2
  
  polyline->getProperty, data=data, color=color, thick=thick
  dims = size(data, /dimensions)
  if (dims[0] eq 3L) then data = data[0:1, *]
  
  data = self->_transformCoords(data, tree=polyline)
  
  path = strjoin(strjoin(strtrim(data, 2), ' ') + ' L ', ' ')
  path = strmid(path, 0, strlen(path) - 3L)  ; remove last L
  format = '(%"<path d=\"M %s\" stroke=\"%s\" stroke-width=\"%f\" ' $
             + 'stroke-linecap=\"round\" stroke-linejoin=\"round\" ' $
             + 'fill-opacity=\"0\"/>")'

  vpr = self->_getVpr(polyline)
  dimsInPts = self->_convertUnits(self.dimensions, self.dimensionUnits, 'pt')
  thick = vpr[3] * self.textMultiplier * thick / min(dimsInPts)
               
  s = string(path, self->_getRgb(color), thick, format=format)  
  printf, lun, indent + s
end


;+
; Handle IDLgrPolygon objects.
;
; :Params:
;    polygon : in, required, type=object
;       IDLgrPolygon object graphics element
;
; :Keywords:
;    lun : in, required, type=long
;       logical unit number of file to write output to
;    indent : in, required, type=string
;       string to prefix each line of output by
;-
pro visgrsvg::_handlePolygon, polygon, lun=lun, indent=indent
  compile_opt strictarr
  on_error, 2
  
  polygon->getProperty, data=data, color=color, thick=thick
  dims = size(data, /dimensions)
  if (dims[0] eq 3L) then message, '3-dimensional polyline data is not supported'
  
  data = self->_transformCoords(data, tree=polygon)
  
  path = strjoin(strjoin(strtrim(data, 2), ' ') + ' L ', ' ')
  path = strmid(path, 0, strlen(path) - 3L)  ; remove last L
  format = '(%"<path d=\"M %s\" stroke-width=\"%f\" ' $
             + 'stroke-linecap=\"round\" stroke-linejoin=\"round\" ' $
             + 'fill-opacity=\"1\" fill=\"%s\"/>")'
  s = string(path, 0., self->_getRgb(color), format=format)
  printf, lun, indent + s
end


;+
; Handle IDLgrText objects.
;
; :Params:
;    text : in, required, type=object
;       IDLgrText object graphics element
;
; :Keywords:
;    lun : in, required, type=long
;       logical unit number of file to write output to
;    indent : in, required, type=string
;       string to prefix each line of output by
;-
pro visgrsvg::_handleText, text, lun=lun, indent=indent
  compile_opt strictarr
  on_error, 2
  
  text->getProperty, strings=strings, locations=locations, color=color, font=font
  locations = self->_transformCoords(locations, tree=text)
  vpr = self->_getVpr(text, dimensions=dims, dimension_units=dimUnits)

  if (obj_valid(font)) then begin
    font->getProperty, name=fontFamily, size=fontSize
  endif else begin
    fontSize = 12
    fontFamily = 'Helvetica'
  endelse
  
  height = self->_convertUnits(self.dimensions[1], self.dimensionUnits, 'pt')
  fontSize = vpr[3] * self.textMultiplier * fontSize / height

  format = '(%"<text x=\"%f\" y=\"%f\" font-family=\"%s\" font-size=\"%f\" fill=\"%s\">%s</text>")'
  s = string(locations[0:1], fontFamily, fontSize, self->_getRgb(color), strings[0], format=format)  
  printf, lun, indent + s
end


;+
; Handle IDLgrImage objects.
;
; :Params:
;    image : in, required, type=object
;       IDLgrImage object graphics element
;
; :Keywords:
;    lun : in, required, type=long
;       logical unit number of file to write output to
;    indent : in, required, type=string
;       string to prefix each line of output by
;-
pro visgrsvg::_handleImage, image, lun=lun, indent=indent
  compile_opt strictarr

  image->getProperty, data=data, location=loc, dimensions=dims, name=name

  loc = self->_transformCoords(loc[0:1], tree=image)
  dims = self->_transformCoords(transpose([[0L, 0L], [dims - 1L]]), tree=image)

  dims = reform(dims[1, *])
  loc[1] -= dims[1]

  name = name eq '' ? '' : ('-' + name)
  urlCount = 0
  url = filepath('image' + name + '-' + strtrim(urlCount++, 2) + '.png', $
                 root=file_dirname(self.filename))

  while (file_test(url)) do begin
    url = filepath('image' + name + '-' + strtrim(urlCount++, 2) + '.png', $
                   root=file_dirname(self.filename))
  endwhile
  
  write_png, url, data

  format = '(%"<image x=\"%f\" y=\"%f\" width=\"%f\" height=\"%f\" xlink:href=\"%s\"/>")'
  s = string(loc, dims, url, format=format)
  
  printf, lun, indent + s  
end


;+
; Handle IDLgrPlot objects.
;
; :Params:
;    plot : in, required, type=object
;       IDLgrPlot object graphics element
;
; :Keywords:
;    lun : in, required, type=long
;       logical unit number of file to write output to
;    indent : in, required, type=string
;       string to prefix each line of output by
;-
pro visgrsvg::_handlePlot, plot, lun=lun, indent=indent
  compile_opt strictarr

  self->_handlePolyline, plot, lun=lun, indent=indent
end


;+
; Handle IDLgrAxis objects.
;
; :Params:
;    axis : in, required, type=object
;       IDLgrAxis object graphics element
;
; :Keywords:
;    lun : in, required, type=long
;       logical unit number of file to write output to
;    indent : in, required, type=string
;       string to prefix each line of output by
;-
pro visgrsvg::_handleAxis, axis, lun=lun, indent=indent
  compile_opt strictarr

  ; TODO: implement
end


;+
; Routine which is recursively called to traverse the object graphics 
; hierarchy.
;
; :Params:
;    tree : in, required, type=object
;       object graphics element
; 
; :Keywords:
;    lun : in, required, type=long
;       logical unit number of file to write output to
;    indent : in, required, type=string
;       string to prefix each line of output by
;-
pro visgrsvg::_traverse, tree, lun=lun, indent=indent
  compile_opt strictarr
  on_error, 2
  
  tree->getProperty, hide=hide
  if (hide) then return  
  indent = n_elements(indent) eq 0L ? '' : indent
  
  case 1 of
    obj_isa(tree, 'IDLgrScene'): self->_handleScene, tree, lun=lun, indent=indent
    obj_isa(tree, 'IDLgrViewGroup'): self->_handleViewgroup, tree, lun=lun, indent=indent
    obj_isa(tree, 'IDLgrView'): self->_handleView, tree, lun=lun, indent=indent
    obj_isa(tree, 'IDLgrModel'): self->_handleModel, tree, lun=lun, indent=indent
    obj_isa(tree, 'IDLgrPolyline'): self->_handlePolyline, tree, lun=lun, indent=indent
    obj_isa(tree, 'IDLgrPolygon'): self->_handlePolygon, tree, lun=lun, indent=indent
    obj_isa(tree, 'IDLgrText'): self->_handleText, tree, lun=lun, indent=indent
    obj_isa(tree, 'IDLgrImage'): self->_handleImage, tree, lun=lun, indent=indent    
    obj_isa(tree, 'IDLgrPlot'): self->_handlePlot, tree, lun=lun, indent=indent    
    obj_isa(tree, 'IDLgrAxis'): self->_handleAxis, tree, lun=lun, indent=indent    
    else: message, 'unknown object graphics element'
  endcase
end


;+
; Write the object graphics rooted at the specified scene or view.
; 
; :Params:
;    tree : in, optional, type=object
;       scene or view object
;-
pro visgrsvg::draw, tree
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
  printf, lun, '<?xml version="1.0" encoding="UTF-8"?>'
  self->_traverse, tree, lun=lun
  free_lun, lun
end


;+
; Set properties.
;-
pro visgrsvg::setProperty, filename=filename, graphics_tree=graphicsTree, $
                           dimensions=dimensions, $
                           em=em, ex=ex, px=px, pt=pt, pc=pc, cm=cm, mm=mm, $
                           inches=inches, percentage=percentage
  compile_opt strictarr

  if (n_elements(filename) gt 0L) then self.filename = filename
  if (n_elements(graphicsTree) gt 0L) then self.graphicsTree = graphicsTree
  if (n_elements(dimensions) gt 0L) then begin
    self.dimensions = dimensions
    case 1 of
      keyword_set(em): self.dimensionUnits = 'em'
      keyword_set(ex): self.dimensionUnits = 'ex'
      keyword_set(px): self.dimensionUnits = 'px'
      keyword_set(pt): self.dimensionUnits = 'pt'
      keyword_set(pc): self.dimensionUnits = 'pc'
      keyword_set(cm): self.dimensionUnits = 'cm'
      keyword_set(mm): self.dimensionUnits = 'mm'
      keyword_set(inches): self.dimensionUnits = 'in'
      keyword_set(percentage): self.dimensionUnits = '%'
      else: self.dimensionUnits = ''
    endcase
  endif
end


;+
; Get properties.
;-
pro visgrsvg::getProperty, filename=filename, graphics_tree=graphicsTree, $
                           text_multipler=textMultiplier, $
                           dimensions=dimensions, dimension_units=dimensionUnits
  compile_opt strictarr
  
  if (arg_present(filename)) then filename = self.filename
  if (arg_present(graphicsTree)) then graphicsTree = self.graphicsTree
  if (arg_present(textMultiplier)) then textMultiplier = self.textMultiplier
  if (arg_present(dimensions)) then dimensions = self.dimensions
  if (arg_present(dimensionUnits)) then dimensionUnits = self.dimensionUnits
end


;+
; Free resources.
;-
pro visgrsvg::cleanup
  compile_opt strictarr
  
  if (obj_valid(self.graphicsTree)) then obj_destroy, self.graphicsTree
end


;+
; Create an SVG destination.
;
; :Returns:
;    1 if successful, 0 if fails
;
; :Keywords:
;    _extra : in, optional, type=keywords
;       any properties of the class
;-
function visgrsvg::init, _extra=e
  compile_opt strictarr

  self.textMultiplier = 1.0
  
  self->setProperty, _extra=e
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    graphicsTree
;       graphics tree to tree if none is provided to draw method
;-
pro visgrsvg__define
  compile_opt strictarr
  
  define = { VISgrSVG, $
             filename: '', $
             graphicsTree: obj_new(), $
             dimensions: fltarr(2), $
             dimensionUnits: '', $
             textMultiplier: 0.0 $
           }
end


; main-level example program

view = obj_new('IDLgrView', viewplane_rect=[1., 1., 2., 2.])
model = obj_new('IDLgrModel')
view->add, model
p1 = obj_new('IDLgrPolyline', $
             [0.1, 0.9, 0.5, 0.1] + 1., $
             [0.1, 0.1, 0.9, 0.1] + 2., $
             thick=4.)
model->add, p1
p2 = obj_new('IDLgrPolyline', $
             2 * [0., 1., 1., 0., 0.] + 1., $
             2. * [0., 0.0, 1., 1., 0.] + 1.)
model->add, p2
p3 = obj_new('IDLgrPolygon', $
             [0.1, 0.9, 0.5, 0.1] + 2., $
             [0.1, 0.1, 0.9, 0.1] + 1., $
             color=[0, 0, 255])
model->add, p3
t = obj_new('IDLgrText', strings='Hello', locations=[1.5, 1.5])
model->add, t

x = findgen(360 * 4) * !dtor
y = sin(x)
xc = vis_linear_function([0., 8.*!pi], [1.1, 1.9])
yc = vis_linear_function([-1., 1.], [1.2, 1.3])
plot = obj_new('IDLgrPlot', x, y, $
               xcoord_conv=xc, ycoord_conv=yc, $
               thick=2, color=[255, 0, 0])
model->add, plot

ali = read_image(file_which('people.jpg'))
xc = vis_linear_function([0, 255], [2., 3.])
yc = vis_linear_function([0, 255], [2., 3.])
im = obj_new('IDLgrImage', ali, xcoord_conv=xc, ycoord_conv=yc, $
             transform_mode=1, name='ali')
model->add, im

model->rotate, [0, 0, 1], 90
model->translate, 4., 0., 0.

win = obj_new('IDLgrWindow', dimensions=[4, 4], units=1)
win->draw, view

svg = obj_new('VISgrSVG', filename='triangle.svg', dimensions=[4, 4], /inches)
svg->draw, view
mg_open_url, 'triangle.svg'

end

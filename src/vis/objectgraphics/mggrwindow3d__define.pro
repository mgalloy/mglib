; docformat = 'rst'

;+
; `MGgrWindow3D` is an object graphics destination for displaying a scene
; as an anaglyph in an `IDLgrWindow`.
; 
; :Categories:
;    object graphics
;
; :Examples:
;    The main-level program at the end of this file contains example code
;    using this class. Run it with::
;
;       IDL> .run mggrwindow3d__define
;
;    It should display:
;
;    .. image:: anaglyph.png
;
; :Properties: 
;    color : type=boolean
;       set to produce color anaglyphs
;    dimensions : type=intarr(2)
;       dimensions of the window
;    eye_separation : type=float
;       number of degrees of the cone formed by drawing lines from each eye to 
;       the origin of the view
;    _extra : out, optional, type=keywords 
;       properties of IDLgrWindow
;-

;+
; Get properties of the `MGgrWindow3D`.
;-
pro mggrwindow3d::getProperty, eye_separation=eyeSeparation, color=color, $
                               _ref_extra=e
  compile_opt strictarr

  if (arg_present(color)) then begin
    self.converter->getProperty, color=color
  endif

  if (arg_present(eyeSeparation)) then begin
    self.converter->getProperty, eye_separation=eyeSeparation
  endif
  
  if (n_elements(e) gt 0) then begin
    self->IDLgrWindow::getProperty, _strict_extra=e
  endif
end


;+
; Set properties of the `MGgrWindow3D`. Must intercept `DIMENSIONS` property to 
; set the converter's buffer size correctly; otherwise, just pass along stuff 
; to `IDLgrWindow`'s setProperty method.
;-
pro mggrwindow3d::setProperty, dimensions=dimensions, $
                               eye_separation=eyeSeparation, color=color, $
                               _extra=e
  compile_opt strictarr

  self->IDLgrWindow::setProperty, _extra=e

  if (n_elements(dimensions) gt 0) then begin
    self->IDLgrWindow::setProperty, dimensions=dimensions
    self.converter->setProperty, dimensions=dimensions
  endif

  if (n_elements(color) gt 0) then begin
    self.converter->setProperty, color=color
  endif

  if (n_elements(eye_separation) gt 0) then begin
    self.converter->setProperty, eye_separation=eyeSeparation
  endif  
end


;+
; Draw the picture in 3D.
;
; :Params:
;    picture : in, optional, type=obj ref
;       the view, viewgroup, or scene to be drawn; if the GRAPHICS_TREE 
;       property is set to a valid picture, then this argument must *not*
;       be given
;-
pro mggrwindow3d::draw, picture
  compile_opt strictarr
  on_error, 2

  self->getProperty, graphics_tree=graphicsTree
  _picture = obj_valid(picture) ? picture : graphicsTree

  view = self.converter->convert(_picture)

  self->idlgrwindow::draw, view
end


;+
; Free resources.
;-
pro mggrwindow3d::cleanup
  compile_opt strictarr

  self->idlgrwindow::cleanup
  obj_destroy, self.converter
end


;+
; Initialize Window3D object.
;
; :Returns: 
;    1 for success, o/w for failure
;-
function mggrwindow3d::init, eye_separation=eyeSeparation, $
                             dimensions=dimensions, color=color, $
                             _extra=e
  compile_opt strictarr
  on_error, 2

  if (n_elements(dimensions) eq 0L) then begin
    case strlowcase(!version.os_family) of
      'unix': begin
          dims = [pref_get('idl_gr_x_width'), pref_get('idl_gr_x_height')]
        end
      'windows': begin
          dims = [pref_get('idl_gr_win_width'), pref_get('idl_gr_win_height')]
        end
      else: message, 'unsupported OS family' 
    endcase
  endif else dims = dimensions
    
  if (~self->IDLgrWindow::init(dimensions=dims, _extra=e)) then return, 0

  self.converter = obj_new('MGgr3dConverter', $
                           eye_separation=eyeSeparation, $
                           color=keyword_set(color), $
                           dimensions=dims, _extra=e)

  return, 1
end


;+
; Destination for object graphics that automatically creates a 3d anaglyph
; appropriate to view with red-blue glasses.
;
; :Fields:
;    converter 
;       object which takes a view and converts to a 3D anaglyph
;-
pro mggrwindow3d__define
  compile_opt strictarr

  define = { MGgrWindow3d, inherits IDLgrWindow, $
             converter: obj_new() $
           }
end


; main-level example program

view = obj_new('IDLgrView', name='view', color=[200, 200, 255])

model = obj_new('IDLgrModel', name='model')
view->add, model

cowFilename = filepath('cow10.sav', subdir=['examples', 'data'])
restore, cowFilename

cow1 = obj_new('IDLgrPolygon', x - 0.15, y, z + 0.25, polygons=polylist, $
               color=[150, 100, 20], shading=1)
model->add, cow1

cow2 = obj_new('IDLgrPolygon', x + 0.15, y, z - 0.25, polygons=polylist, $
               color=[150, 100, 20], shading=1)
model->add, cow2

xmin = min(x, max=xmax)
xrange = xmax - xmin
ymin = min(y, max=ymax)
yrange = ymax - ymin
zmin = min(z, max=zmax)
zrange = zmax - zmin

plane = obj_new('IDLgrPolygon', $
                0.75 * [-1, -1, 1, 1], $
                fltarr(4) + ymin, $
                0.75 * [-1, 1, 1, -1], $
                color=[25, 100, 50], style=2)
model->add, plane

model->rotate, [0, 1, 0], -45
model->rotate, [1, 0, 0], 30

light = obj_new('IDLgrLight', type=2, location=[0, 5, 5], intensity=1.0)
model->add, light
alight = obj_new('IDLgrLight', type=0, intensity=1.0)
model->add, alight

window3d = obj_new('MGgrWindow3d', dimensions=[640, 512], /color)
window3d->draw, view

end

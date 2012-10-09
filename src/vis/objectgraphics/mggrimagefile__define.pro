; docformat = 'rst'

;+
; Create an image file destination for an object graphics scene.
;
; :Categories:
;    object graphics
;
; :Examples:
;    Try the main-level program at the end of this file::
;
;       IDL> .run mggrimagefile__define
;
;    This should produce:
;
;    .. image:: surface.png
;
; :Properties:
;    filename : type=string
;       filename to send output to
;    vector : type=boolean
;       set to produce vector output that is then converted to raster output
;    _extra : type=keywords
;       keywords to IDLgrBuffer and IDLgrClipboard
;-

;+
; Get properties of the image file destination.
;-
pro mggrimagefile::getProperty, filename=filename, vector=vector, _ref_extra=e
  compile_opt strictarr

  if (arg_present(filename)) then filename = self.filename
  if (arg_present(vector)) then vector = self.vector

  if (n_elements(e) gt 0L) then begin
    self.buffer->getProperty, _extra=e
    self.clipboard->getProperty, _extra=e
  endif
end


;+
; Set properties of the image file destination.
;-
pro mggrimagefile::setProperty, filename=filename, vector=vector, _extra=e
  compile_opt strictarr

  if (n_elements(filename) gt 0L) then self.filename = filename
  if (n_elements(vector) gt 0L) then self.vector = vector

  if (n_elements(e) gt 0L) then begin
    self.buffer->setProperty, _extra=e
    self.clipboard->setProprty, _extra=e
  endif
end


;+
; Draw the given scene to an image file.
;
; :Params:
;    picture : in, optional, type=objref
;       scene, viewgroup, or view to draw
;-
pro mggrimagefile::draw, picture
  compile_opt strictarr
  on_error, 2

  dotpos = strpos(self.filename, '.', /reverse_search)
  if (dotpos lt 0L) then message, 'unknown image extension'
  format = strmid(self.filename, dotpos + 1L)

  if (n_elements(picture) eq 0L) then begin
    self.buffer->getProperty, graphics_tree=_picture
  endif else begin
    _picture = picture
  endelse

  if (self.vector) then begin
    basename = strmid(self.filename, 0, dotpos)
    self.clipboard->draw, _picture, /vector, /postscript, $
                          filename=basename + '.ps'
    self.clipboard->getProperty, dimensions=dims
    mg_convert, basename, /from_ps, to_extension=format, max_dimensions=dims
    file_delete, basename + '.ps'
  endif else begin
    self.buffer->draw, _picture
    self.buffer->getProperty, image_data=im, color_model=cm, palette=palette
    case cm of
      0: write_image, self.filename, format, im
      1: begin
          palette->getProperty, red_values=r, green_values=g, blue_values=b
          write_image, self.filename, format, im, r, g, b
        end
      else: message, 'unknown color model'
    endcase

  endelse
end


;+
; Free resources.
;-
pro mggrimagefile::cleanup
  compile_opt strictarr

  obj_destroy, [self.buffer, self.clipboard]
end


;+
; Create an image file destination.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mggrimagefile::init, filename=filename, vector=vector, _extra=e
  compile_opt strictarr

  self.filename = n_elements(filename) eq 0L ? '' : filename
  self.vector = keyword_set(vector)

  self.buffer = obj_new('IDLgrBuffer', _extra=e)
  self.clipboard = obj_new('IDLgrClipboard', _extra=e)

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    filename
;       filename of output file
;-
pro mggrimagefile__define
  compile_opt strictarr

  define = { MGgrImageFile, $
             filename: '',  $
             vector: 0B, $
             buffer: obj_new(), $
             clipboard: obj_new() $
           }
end


; main-level example program

view = obj_new('IDLgrView')

model = obj_new('IDLgrModel')
view->add, model

surf = obj_new('IDLgrSurface', hanning(20, 20), $
               color=[255, 0, 0], bottom=[128, 0, 0], $
               style=2)
model->add, surf

lightmodel = obj_new('IDLgrModel')
view->add, lightmodel

light = obj_new('IDLgrLight', type=2, location=[-0.5, -1., 1.])
lightmodel->add, light

surf->getProperty, xrange=xr, yrange=yr, zrange=zr
xc = mg_linear_function(xr, [-0.55, 0.55])
yc = mg_linear_function(yr, [-0.55, 0.55])
zc = mg_linear_function(zr, [-0.4, 0.4])
surf->setProperty, xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc

xaxis = obj_new('IDLgrAxis', 0, range=xr, /exact, $
                xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc)
model->add, xaxis

yaxis = obj_new('IDLgrAxis', 1, range=yr, /exact, $
                xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc)
model->add, yaxis

zaxis = obj_new('IDLgrAxis', 2, range=zr, /exact, $
                xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc)
model->add, zaxis

model->rotate, [1, 0, 0], -90
model->rotate, [0, 1, 0], 45
model->rotate, [1, 0, 0], 20

imagefile = obj_new('MGgrImageFile', filename='surface.png', /vector, $
                    dimensions=[400, 400])
imagefile->draw, view

win = obj_new('IDLgrWindow')
win->draw, view

end

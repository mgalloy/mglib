; docformat = 'rst'

;+
; Class to convert a 3-dimensional scene to an anaglyph.
;
; This is not done the "correct" way i.e. as described in::
;
;    http://www.triplespark.net/render/stereo/create.html
;
; Better results were achieved with a simple rotation.
;
; :Categories:
;    object graphics
;
; :Properties:
;    color : type=boolean
;       set to create color anaglyphs
;    eye_separation : type=float
;       number of degrees of the cone formed by drawing lines from each eye to
;       the origin
;    dimensions : type=intarr(2)
;       dimensions of the window
;    _extra : type=keywords
;       properties of IDLgrBuffer
;
; :Author:
;    Michael Galloy
;-

;+
; Creates a combined image from images from the left and right eyes where the
; left eye is "shaded" red and the right eye is "shaded" blue.
;
; :Private:
;
; :Returns:
;    bytarr(3, xsize, ysize)
;
; :Params:
;    leftImage : in, optional, type="bytarr(3, xsize, ysize)"
;       image from left eye
;    rightImage : in, optional, type="bytarr(3, xsize, ysize)"
;       image from right eye
;-
function mggr3dconverter::_combineImages, leftImage, rightImage
  compile_opt strictarr

  ; define combined_image to the correct size
  combinedImage = leftImage * 0B
  dims = size(leftImage, /dimensions)

  if (self.color) then begin
    combinedImage[0, *, *] = leftImage[0, *, *]
    combinedImage[1, *, *] = rightImage[1, *, *]
    combinedImage[2, *, *] = rightImage[2, *, *]
  endif else begin
    _leftImage = byte(total(fix(leftImage), 1) / 3)
    _rightRight = byte(total(fix(rightImage), 1) / 3)

    combinedImage[0, 0, 0] = Reform(_leftImage, 1, dims[1], dims[2])
    combinedImage[1, 0, 0] = Reform(_rightRight, 1, dims[1], dims[2])
    combinedImage[2, 0, 0] = Reform(_rightRight, 1, dims[1], dims[2])
  endelse

  return, combinedImage
end


;+
; Rotates "top-level" models of the given picture by the given number of
; degrees about the y-axis.
;
; :Private:
;
; :Params:
;    picture : in, required, type=obj ref
;       the view, viewgroup, or scene to be drawn
;    degrees : in, required, type=float
;       number of degrees to rotate "top-level" models
;-
pro mggr3dconverter::_rotateModels, picture, degrees
  compile_opt strictarr

  ; if picture is a model then rotate it, but don't rotate models inside it
  if (obj_isa(picture, 'IDLgrModel')) then begin
    picture->rotate, [0, 1, 0], degrees
    return
  endif

  if (obj_isa(picture, 'IDL_Container')) then begin
    items = picture->get(/all, count=count)
    for i = 0L, count - 1 do begin
      self->_rotateModels, items[i], degrees
    endfor
  endif
end


;+
; Converts a standard object graphics picture to a view containing a 3D image.
;
; :Returns:
;    IDLgrView object reference
;
; :Params:
;    picture : in, optional, type=object
;       the view, viewgroup, or scene to be drawn; if the GRAPHICS_TREE
;       property is set to a valid picture, then this argument must *not* be
;       given
;-
function mggr3dconverter::convert, picture
  compile_opt strictarr

  ; rotate "top-level" models for left eye
  self->_rotateModels, picture, self.eyeSeparation / 2.

  ; draw picture to left eye buffer
  self.buffer->draw, picture

  ; get data out of left eye buffer
  oleftImage = self.buffer->read()
  oleftImage->getProperty, data=leftImage
  obj_destroy, oleftImage

  ; rotate "top-level" models for right eye
  self->_rotateModels, picture, - self.eyeSeparation

  ; draw picture to right eye buffer
  self.buffer->draw, picture

  ; get data out of left eye buffer
  orightImage = self.buffer->read()
  orightImage->getProperty, data=rightImage
  obj_destroy, orightImage

  ; rotate "top-level" models back to center
  self->_rotateModels, picture, self.eyeSeparation / 2.

  combinedImage = self->_combineImages(leftImage, rightImage)

  self.image->setProperty, data=combinedImage

  return, self.view
end


;+
; Get properties of the converter.
;-
pro mggr3dconverter::getProperty, eye_separation=eyeSeparation, $
                                  dimensions=dimensions, color=color, $
                                  _ref_extra=e
  compile_opt strictarr

  if (arg_present(color)) then begin
    color = self.color
  endif

  if (arg_present(eyeSeparation)) then begin
    eyeSeparation = self.eyeSeparation
  endif

  if (arg_present(dimensions)) then begin
    self.buffer->getProperty, dimensions=dimensions
  endif

  if (n_elements(e) gt 0L) then begin
    self.buffer->getProperty, _extra=e
  endif
end


;+
; Set properties of the converter.
;-
pro mggr3dconverter::setProperty, eye_separation=eyeSeparation, $
                                  dimensions=dimensions, color=color, $
                                  _extra=e
  compile_opt strictarr

  if (n_elements(color) gt 0L) then begin
    self.color = color
  endif

  if (n_elements(eye_separation) gt 0L) then begin
    self.eyeSeparation = eyeSeparation
  endif

  if (n_elements(dimensions) gt 0L) then begin
    self.view->setProperty, viewplace_rect=[0, 0, dimensions]
    self.buffer->setProperty, dimensions=dimensions
  endif

  if (n_elements(e) gt 0L) then begin
    self.buffer->setProperty, _extra=e
  endif
end


;+
; Free resources.
;-
pro mggr3dconverter::cleanup
  compile_opt strictarr

  obj_destroy, [self.view, self.buffer]
end


;+
; Initialize Window3D.
;
; :Returns:
;    1 for success, o/w for failure
;
; :Keywords:
;    _extra : in, optional, type=keywords
;       keywords to IDLgrBuffer::init method are accepted
;-
function mggr3dconverter::init, eye_separation=eyeSeparation, $
                                dimensions=dimensions, color=color, $
                                _extra=e
  compile_opt strictarr

  self.color = keyword_set(color)
  self.eyeSeparation = n_elements(eyeSeparation) eq 0 ? 4.0 : eyeSeparation

  self.buffer = obj_new('IDLgrBuffer', dimensions=dimensions, _extra=e)

  self.view = obj_new('IDLgrView', viewplane_rect=[0, 0, dimensions])

  model = obj_new('IDLgrModel')
  self.view->add, model

  self.image = obj_new('IDLgrImage')
  model->add, self.image

  return, 1
end


;+
; Helper object to transform a normal object graphics scene to a 3D picture.
;
; :Fields:
;    color
;       set to produce color anaglyphs
;    eyeSeparation
;       number of degrees of the cone formed by drawing lines from each eye to
;       the origin
;    buffer
;       IDLgrBuffer to send left and right eye images to and extract
;    view
;       IDLgrView to contain the 3D image
;    image
;       IDLgrImage actually being displayed
;-
pro mggr3dconverter__define
  compile_opt strictarr

  define = { MGgr3dConverter, $
             eyeSeparation: 0.0, $
             color: 0B, $
             buffer: obj_new(), $
             view: obj_new(), $
             image: obj_new() $
           }
end

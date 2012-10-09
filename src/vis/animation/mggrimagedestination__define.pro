; docformat = 'rst'

;+
; Image destination for object graphics.
;
; :Properties:
;    basename
;       basename of image filename
;    format
;       image format: bmp, gif, jpeg, png, ppm, srf, tiff
;    show_frame
;       set to put frame number in output filenames
;    frame_format
;       format code used for including frame number in output filenames
;    _extra
;       properties of `IDLgrBuffer`
;-

;+
; Draw the scene.
;
; :Params:
;    picture : in, optional, type=object
;       scene, view group, or view to draw
;-
pro mggrimagedestination::draw, picture
  compile_opt strictarr

  self->idlgrbuffer::draw, picture
  self->getProperty, image_data=image

  frame = keyword_set(self.showFrame) $
            ? string(self.currentFrame++, format=self.frameFormat) $
            : ''
  write_image, self.basename + frame + '.' + self.format, self.format, image
end


;+
; Get properties.
;-
pro mggrimagedestination::getProperty, basename=basename, $
                                       format=format, $
                                       show_frame=showFrame, $
                                       frame_format=frameFormat, $
                                       _ref_extra=e
  compile_opt strictarr

  if (arg_present(basename)) then basename = self.basename
  if (arg_present(format)) then format = self.format
  if (arg_present(showFrame)) then showFrame = self.showFrame
  if (arg_present(frameFormat)) then frameFormat = self.frameFormat

  if (n_elements(e) gt 0L) then self->idlgrbuffer::getProperty, _extra=e
end


;+
; Set properties.
;-
pro mggrimagedestination::setProperty, basename=basename, $
                                       format=format, $
                                       show_frame=showFrame, $
                                       frame_format=frameFormat, $
                                       _extra=e
  compile_opt strictarr

  if (n_elements(basename) gt 0L) then self.basename = basename
  if (n_elements(format) gt 0L) then self.format = format
  if (n_elements(showFrame) gt 0L) then self.showFrame = showFrame
  if (n_elements(frameFormat) gt 0L) then self.frameFormat = frameFormat

  if (n_elements(e) gt 0L) then self->idlgrbuffer, setProperty, _extra=e
end


;+
; Free resources.
;-
pro mggrimagedestination::cleanup
  compile_opt strictarr

  self->idlgrbuffer::cleanup
end


;+
; Create image destination.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mggrimagedestination::init, basename=basename, $
                                     format=format, $
                                     show_frame=showFrame, $
                                     frame_format=frameFormat, $
                                     _extra=e
  compile_opt strictarr

  if (~self->idlgrbuffer::init(_extra=e)) then return, 0

  self.basename = basename
  self.format = n_elements(format) eq 0L ? 'png' : strlowcase(format)
  self.showFrame = keyword_set(showFrame)
  self.currentFrame = 1L
  self.frameFormat = n_elements(frameFormat) eq 0L ? '(I05)' : frameFormat

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    basename
;       base filename without extension or frame number
;    format
;       format to output images: bmp, gif, jpeg, png, ppm, srf, tiff
;    frameFormat
;       format code for printing current frame number in output filename
;    showFrame
;       set if the current frame number should be placed in the output
;       filename
;    currentFrame
;       current frame number in the animation
;-
pro mggrimagedestination__define
  compile_opt strictarr

  define = { MGgrImageDestination, inherits IDLgrBuffer, $
             basename: '', $
             format: '', $
             frameFormat: '', $
             showFrame: 0B, $
             currentFrame: 0L $
           }
end
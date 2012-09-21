;+
; Generate a single frame of the animation.
; 
; @param view {in}{required}{type=object} IDLgrScene, IDLgrViewGroup, IDLgrview
;        to draw
; @keyword frame {in}{required}{type=long} frame number to draw
; @keyword nframes {in}{required}{type=long} total number of frames to draw
;-
pro mggrimagesequenceanimation::renderFrame, view, frame=frame, nframes=nframes
  compile_opt strictarr

  self.obuffer->draw, view
  oimage = self.obuffer->read()
  oimage->getProperty, data=im
  obj_destroy, oimage

  strDigits = strtrim(ceil(alog10(nframes)), 2)
  format = '(I' + strDigits + '.' + strDigits + ')'

  write_png, self.baseFilename + string(frame, format=format) + '.png', im  
end


;+
; Free resources.
;-
pro mggrimagesequenceanimation::cleanup
  compile_opt strictarr

  obj_destroy, self.obuffer
  self->mggranimation::cleanup
end


;+
; Initialize Mggrimagesequenceanimation.
; 
; @returns 1 for success, 0 otherwise
; @keyword base_filename {in}{required}{type=string} basename of files in the
;          image sequence output
; @keyword _extra {in}{optional}{type=keywords} keywords to IDLgrBuffer::init
;-
function mggrimagesequenceanimation::init, base_filename=base_filename, _extra=e
  compile_opt strictarr

  if (~self->mggranimation::init()) then return, 0

  if (n_elements(base_filename) eq 0) then begin
    message, 'BASE_FILENAME property required.'
    return, 0
  endif

  self.baseFilename = base_filename
  self.obuffer = obj_new('IDLgrBuffer', _extra=e)

  return, 1
end


;+
; Define member variables.
; 
; @file_comments A MGgrImageSequenceAnimation represents an animation which is
;                output to a sequence of images.
; @field obuffer IDLgrBuffer used to render the frames
; @field baseFilename base filename to output image sequence
;-
pro mggrimagesequenceanimation__define
  compile_opt strictarr

  define = { MGgrImageSequenceAnimation, $
             inherits MGgrAnimation, $
             obuffer : obj_new(), $
             baseFilename : '' $
           }
end

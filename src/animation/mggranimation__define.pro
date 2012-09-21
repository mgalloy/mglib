;+
; This method must be over-ridden by each concrete subclass to actually render 
; an individual frame.
;
; @abstract
; @keyword frame {in}{required}{type=long} frame number to render (starts at 0)
; @keyword nframes {in}{type=long} total number of frames in animation
;-
pro mggranimation::renderFrame, frame=frame, nframes=nframes
  compile_opt strictarr

end


;+
; Draw the animation.
;
; @param view {in}{required}{type=object} IDLgrView, IDLgrScene, or
;        IDLgrViewGroup
;-
pro mggranimation::draw, view
  compile_opt strictarr, logical_predicate

  nAnimators = self.animators->count()
  frame = 0
  
  nframes = 0
  for a = 0L, nAnimators - 1L do begin
    oanimator = self.animators->get(position=a)
    oanimator->getProperty, nframes=nAnimatorFrames, startFrame=startFrame
    nframes = nframes > (nAnimatorFrames + startFrame)
  endfor

  for frame = 0L, nframes - 1L do begin
    for a = 0L, nAnimators - 1L do begin
      oanimator = self.animators->get(position=a)
      oanimator->apply, frame=frame
    endfor
    self->renderFrame, view, frame=frame, nframes=nframes
  endfor
end


;+
; Add animator to the animation.
;
; @param animator {in}{required}{type=object} MGgrAnimator object
;-
pro mggranimation::addAnimator, animator
  compile_opt strictarr

  self.animators->add, animator
end


;+
; Free resources.
;-
pro mggranimation::cleanup
  compile_opt strictarr

  obj_destroy, self.animators
end


;+
; Initialize object.
;
; @returns 1 for success, 0 otherwise
;-
function mggranimation::init
  compile_opt strictarr

  self.animators = obj_new('IDL_Container')

  return, 1
end


;+
; Define member variables.
;
; @file_comments A MGgrAnimation is a destination for an object graphics
;                hierarchy. MGgrAnimation itself is abstract so a particular
;                concrete subclass of it must be used.
; @field animators list of animators
;-
pro mggranimation__define
  compile_opt strictarr

  define = { MGgrAnimation, $
             animators : obj_new() $
           }
end

;+
; Get properties of the animator.
;
; @keyword startFrame {out}{optional}{type=long} first frame of the animator
;-
pro mggranimator::getProperty, startFrame=startFrame
  compile_opt strictarr

  if (arg_present(startFrame)) then startFrame = self.startFrame
end


;+
; Free resources.
;-
pro mggranimator::cleanup
  compile_opt strictarr

end


;+
; Initialize object.
;
; @returns 1 for success; 0 otherwise
; @keyword target {in}{required}{type=object} IDLgrModel that should be acted 
;          upon
; @keyword start_frame {in}{optional}{type=long} index of the animation that 
;          this animator should start acting
;-
function mggranimator::init, target=target, start_frame=start_frame
  compile_opt strictarr

  self.target = target
  self.startFrame = n_elements(start_frame) eq 0 ? 0L : start_frame

  return, 1
end


;+
; Define member variables.
; 
; @file_comments This class represents changes to a given target during
;                certain steps in an animation.
; @field target IDLgrModel that this animator acts on
; @field startFrame frame of the animation that this animator starts on
;-
pro mggranimator__define
  compile_opt strictarr

  define = { MGgrAnimator, $
             target : obj_new(), $
             startFrame : 0L $
           }
end

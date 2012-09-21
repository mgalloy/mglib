;+
; A MGgrWindowAnimation represents an animation that will be displayed in an 
; IDLgrWindow.
;-

;+
; Generate a single frame of the animation.
; 
; @param view {in}{required}{type=object} IDLgrScene, IDLgrViewGroup, IDLgrview
;        to draw
; @keyword frame {in}{required}{type=long} frame number to draw; not used
; @keyword nframes {in}{required}{type=long} total number of frames to draw; not
;          used
;-
pro mggrwindowanimation::renderFrame, view, frame=frame, nframes=nframes
  compile_opt strictarr

  self->idlgrwindow::draw, view
end


;+
; Free resources.
;-
pro mggrwindowanimation::cleanup
  compile_opt strictarr

  self->idlgrwindow::cleanup
  self->mggranimation::cleanup
end


;+
; Initialize an MGgrWindowAnimation.
;
; @returns 1 for success, 0 otherwise
; @keyword _extra {in}{optional}{type=keywords} keywords to IDLgrWindow::init
;-
function mggrwindowanimation::init, _extra=e
  compile_opt strictarr

  if (~self->mggranimation::init()) then return, 0
  if (~self->idlgrwindow::init(_extra=e)) then return, 0

  return, 1
end


;+
; Define member variables.
;-
pro mggrwindowanimation__define
  compile_opt strictarr

  define = { mggrwindowanimation, $
             inherits MGgrAnimation, $
             inherits IDLgrWindow $
           }
end

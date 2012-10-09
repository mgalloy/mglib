; docformat = 'rst'

;+
; Base animator.
;
; :Properties:
;    target
;       target object of the animator
;    duration
;       the duration of the animator in seconds; defaults to 1.0 second
;    nframes
;       the number of frames produces by the animator; defaults to 100 frames
;    easing
;       easing object to use for transitions; defaults to a linear easing
;-


;+
; Do one frame of animation. MGgrAnimator has a null animation.
;
; :Params:
;    progress : in, required, type=float
;       progress from 0.0 to 1.0
;-
pro mggranimator::animate, progress
  compile_opt strictarr

end


;+
; Reset the animator.
;-
pro mggranimator::reset
  compile_opt strictarr

  self.currentProgress = 0.0
end


;+
; Get properties.
;-
pro mggranimator::getProperty, target=target, duration=duration, $
                               nframes=nframes, easing=easing
  compile_opt strictarr

  if (arg_present(target)) then target = self.target
  if (arg_present(duration)) then duration = self.duration
  if (arg_present(nframes)) then nframes = self.nframes
  if (arg_present(easing)) then easing = self.easing
end


;+
; Set properties.
;-
pro mggranimator::setProperty, target=target, duration=duration, $
                               nframes=nframes, easing=easing
  compile_opt strictarr

  if (n_elements(target) gt 0L) then self.target = target
  if (n_elements(duration) gt 0L) then self.duration = duration
  if (n_elements(nframes) gt 0L) then self.nframes = nframes
  if (n_elements(easing) gt 0L) then begin
    obj_destroy, self.easing
    self.easing = easing
  endif
end


;+
; Free resources.
;-
pro mggranimator::cleanup
  compile_opt strictarr

  obj_destroy, self.easing
end


;+
; Create an animator.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mggranimator::init, target=target, duration=duration, $
                             nframes=nframes, easing=easing
  compile_opt strictarr

  self.target = n_elements(target) gt 0L ? target : obj_new()
  self.duration = n_elements(duration) gt 0L ? duration : 1.0
  self.nframes = n_elements(nframes) gt 0L ? nframes : 100L
  self.easing = (obj_valid(easing) && obj_isa(easing, 'MGgrEasing')) $
                  ? easing $
                  : obj_new('MGgrEasing')

  return, 1L
end


;+
; Define instance variables.
;
; :Fields:
;    target
;       target object of the animator
;    duration
;       the duration of the animator in seconds; defaults to 1.0 second
;    nframes
;       the number of frames produces by the animator; defaults to 100 frames
;    easing
;       easing object to use for transitions; defaults to a linear easing
;    currentProgress
;       current progress 0. to 1. of the animator
;-
pro mggranimator__define
  compile_opt strictarr

  define = { MGgrAnimator, $
             target: obj_new(), $
             duration: 0.0, $
             nframes: 0L, $
             easing: obj_new(), $
             currentProgress: 0.0 $
           }
end
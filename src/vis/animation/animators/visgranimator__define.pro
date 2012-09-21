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
; Do one frame of animation. VISgrAnimator has a null animation.
;
; :Params:
;    progress : in, required, type=float
;       progress from 0.0 to 1.0
;-
pro visgranimator::animate, progress
  compile_opt strictarr
  
end


;+
; Reset the animator.
;-
pro visgranimator::reset
  compile_opt strictarr

end


;+
; Get properties.
;-
pro visgranimator::getProperty, target=target, duration=duration, $
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
pro visgranimator::setProperty, target=target, duration=duration, $
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
pro visgranimator::cleanup
  compile_opt strictarr
  
  obj_destroy, self.easing
end


;+
; Create an animator.
;
; :Returns:
;    1 for success, 0 for failure
;-
function visgranimator::init, target=target, duration=duration, $
                              nframes=nframes, easing=easing
  compile_opt strictarr
  
  self.target = n_elements(target) gt 0L ? target : obj_new()  
  self.duration = n_elements(duration) gt 0L ? duration : 1.0
  self.nframes = n_elements(nframes) gt 0L ? nframes : 100L
  self.easing = (obj_valid(easing) && obj_isa(easing, 'VISgrEasing')) $
                  ? easing $
                  : obj_new('VISgrEasing')
  
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
;-
pro visgranimator__define
  compile_opt strictarr
  
  define = { VISgrAnimator, $
             target: obj_new(), $
             duration: 0.0, $
             nframes: 0L, $
             easing: obj_new() $
           }
end
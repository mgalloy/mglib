; docformat = 'rst'

;+
; Parallel animator for holding animator that should happen at the same time.
; 
; :Properties:
;    duration
;       duration of the animator
;    _ref_extra
;       properties of the VISgrAnimation or IDL_Container
;-

;+
; Get properties.
;-
pro visgrparallelanimator::getProperty, duration=duration, _ref_extra=e
  compile_opt strictarr
  
  if (arg_present(duration)) then begin
    duration = 0.0
    for i = 0L, self->count() - 1L do begin
      animator = self->get(position=i)
      animator->getProperty, duration=d
      duration >= d
    endfor
  endif
  
  if (n_elements(e) gt 0L) then begin
    self->visgranimator::getProperty, _extra=e
    self->idl_container::getProperty, _extra=e
  endif
end


;+
; Do the transition.
;
; :Params:
;    progress : in, required, type=float
;       progress of the transition, 0 to 1
;-
pro visgrparallelanimator::animate, progress
  compile_opt strictarr

  _progress = self.easing->ease(progress)
  
  count = self->count() 
  all = self->get(/all)
  
  ; TODO: this will have to change to use durations
  for i = 0L, count - 1L do all[i]->animate, _progress
end


;+
; Reset the animator.
;-
pro visgrparallelanimator::reset
  compile_opt strictarr
  
  for i =  0L, self->count() - 1L do begin
    animator = self->get(position=i)
    animator->reset
  endfor
end


;+
; Define the instance variables.
;
; :Fields:
;    container
;       container object to hold parallel animators
;-
pro visgrparallelanimator__define
  compile_opt strictarr
  
  define = { VISgrParallelAnimator, $
             inherits VISgrAnimator, $
             inherits IDL_Container, $
             container: obj_new() $
           }
end
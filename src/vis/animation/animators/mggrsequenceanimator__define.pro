; docformat = 'rst'

;+
; Parallel animator for holding animator that should happen one after the
; other.
;
; :Properties:
;    duration
;       duration of the animator
;    _ref_extra
;       properties of the `MGgrAnimation` or `IDL_Container`
;-

;+
; Get properties.
;-
pro mggrsequenceanimator::getProperty, duration=duration, _ref_extra=e
  compile_opt strictarr

  if (arg_present(duration)) then begin
    duration = 0.0
    for i = 0L, self->count() - 1L do begin
      animator = self->get(position=i)
      animator->getProperty, duration=d
      duration += d
    endfor
  endif

  if (n_elements(e) gt 0L) then begin
    self->mggranimator::getProperty, _extra=e
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
pro mggrsequenceanimator::animate, progress
  compile_opt strictarr

  _progress = self.easing->ease(progress)

  ; TODO: this will have to change to take into account the different durations
  count = self->count()
  ind = where(_progress le findgen(count + 1L) / count) - 1L
  animator = self->get(position=ind[0])

  animator->animate, _progress * count - ind[0]
end


;+
; Reset the animator.
;-
pro mggrsequenceanimator::reset
  compile_opt strictarr

  self->MGgrAnimator::reset
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
;       container object to hold sequential animators
;-
pro mggrsequenceanimator__define
  compile_opt strictarr

  define = { MGgrSequenceAnimator, $
             inherits MGgrAnimator, $
             inherits IDL_Container, $
             container: obj_new() $
           }
end
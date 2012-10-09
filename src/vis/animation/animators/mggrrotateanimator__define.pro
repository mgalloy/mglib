; docformat = 'rst'

;+
; Rotate animator.
;
; :Properties:
;    angle
;       degrees to rotate
;    axis
;       axis to rotate about
;-

;+
; Do the transition.
;
; :Params:
;    progress : in, required, type=float
;       progress of the transition, 0 to 1
;-
pro mggrrotateanimator::animate, progress
  compile_opt strictarr

  _progress = self.easing->ease(progress)

  a = (_progress - self.currentProgress) * self.angle
  self.target->rotate, self.axis, a

  self.currentProgress = _progress
end


;+
; Create a rotate animator.
;
; :Returns:
;    1 for success, 0 for failure
;
; :Keywords:
;    angle : in, optional, type=float
;       degrees to rotate
;    axis : in, optional, type=fltarr(3), default="[1, 0, 0]"
;       axis to rotate about
;    _extra : in, optional, type=keywords
;       keyword to `MGgrAnimator::init`
;-
function mggrrotateanimator::init, angle=angle, axis=axis, _extra=e
  compile_opt strictarr

  if (~self->mggranimator::init(_extra=e)) then return, 0

  self.angle = n_elements(angle) eq 0L ? fltarr(3) + 1.0 : angle
  self.axis = n_elements(axis) eq 0L ? fltarr(3) + 1.0 : axis

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    angle
;       degrees to rotate
;    axis
;       axis to rotate about
;-
pro mggrrotateanimator__define
  compile_opt strictarr

  define = { MGgrRotateAnimator, inherits MGgrAnimator, $
             angle: 0.0, $
             axis: fltarr(3) $
           }
end
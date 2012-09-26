; docformat = 'rst'

;+
; Transform animator.
;
; :Properties:
;    transform
;       transform to apply
;-

;+
; Do the transition.
;
; :Params:
;    progress : in, required, type=float
;       progress of the transition, 0 to 1
;-
pro mggrtransformanimator::animate, progress
  compile_opt strictarr
  
  _progress = self.easing->ease(progress)
  
  ; TODO: apply self.transform a `_progress - self.currentProgress` amount
  ;s = exp((_progress - self.currentProgress) * alog(self.size))
  ;self.target->scale, s[0], s[1], s[2]
  
  self.currentProgress = _progress
end


;+
; Reset the animator.
;-
pro mggrtransformanimator::reset
  compile_opt strictarr
  
  self.currentProgress = 0.0
end


;+
; Create a transform animator.
;
; :Returns:
;    1 for success, 0 for failure
;
; :Keywords:
;    transform : in, optional, type=fltarr(3)
;       transform to apply
;    _extra : in, optional, type=keywords
;       keyword to `MGgrAnimator::init`
;-
function mggrtransformanimator::init, transform=transform, _extra=e
  compile_opt strictarr

  if (~self->mggranimator::init(_extra=e)) then return, 0
  
  self.transform = n_elements(transform) eq 0L ? fltarr(3) + 1.0 : transform
  
  return, 1
end


;+
; Define instance variables.
; 
; :Fields:
;    size
;       amount to scale each dimension
;-
pro mggrtransformanimator__define
  compile_opt strictarr
  
  define = { MGgrTransformAnimator, inherits MGgrAnimator, $
             transform: fltarr(4, 4), $
             currentProgress: 0.0 $
           }
end
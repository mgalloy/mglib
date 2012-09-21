; docformat = 'rst'

;+
; Scale animator.
;
; :Properties:
;    size
;       amount to scale each dimension
;-

;+
; Do the transition.
;
; :Params:
;    progress : in, required, type=float
;       progress of the transition, 0 to 1
;-
pro visgrscaleanimator::animate, progress
  compile_opt strictarr
  
  _progress = self.easing->ease(progress)
  
  s = (1. + _progress) / (1. + self.currentProgress) * self.size / 2.0
  self.target->scale, s[0], s[1], s[2]
  
  self.currentProgress = _progress
end


;+
; Reset the animator.
;-
pro visgrscaleanimator::reset
  compile_opt strictarr
  
  self.currentProgress = 0.0
end


;+
; Create a scale animator.
;
; :Returns:
;    1 for success, 0 for failure
;
; :Keywords:
;    size : in, optional, type=fltarr(3)
;       amount to scale each dimension
;    _extra : in, optional, type=keywords
;       keyword to VISgrAnimator::init
;-
function visgrscaleanimator::init, size=size, _extra=e
  compile_opt strictarr

  if (~self->visgranimator::init(_extra=e)) then return, 0
  
  self.size = n_elements(size) eq 0L ? fltarr(3) + 1.0 : size
  
  return, 1
end


;+
; Define instance variables.
; 
; :Fields:
;    size
;       amount to scale each dimension
;-
pro visgrscaleanimator__define
  compile_opt strictarr
  
  define = { VISgrScaleAnimator, inherits VISgrAnimator, $
             size: fltarr(3), $
             currentProgress: 0.0 $
           }
end
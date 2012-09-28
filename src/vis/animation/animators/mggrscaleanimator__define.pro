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
pro mggrscaleanimator::animate, progress
  compile_opt strictarr
  
  _progress = self.easing->ease(progress)
  
  s = exp((_progress - self.currentProgress) * alog(self.size))
  self.target->scale, s[0], s[1], s[2]
  
  self.currentProgress = _progress
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
;       keyword to `MGgrAnimator::init`
;-
function mggrscaleanimator::init, size=size, _extra=e
  compile_opt strictarr

  if (~self->mggranimator::init(_extra=e)) then return, 0
  
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
pro mggrscaleanimator__define
  compile_opt strictarr
  
  define = { MGgrScaleAnimator, inherits MGgrAnimator, $
             size: fltarr(3) $
           }
end
; docformat = 'rst'

;+
; Translate animator.
;
; :Properties:
;    translation
;       amount to translate each dimension
;-

;+
; Do the transition.
;
; :Params:
;    progress : in, required, type=float
;       progress of the transition, 0 to 1
;-
pro visgrtranslateanimator::animate, progress
  compile_opt strictarr
  
  _progress = self.easing->ease(progress)
  
  trans = (_progress - self.currentProgress) * self.translation
  self.target->translate, trans[0], trans[1], trans[2]
  
  self.currentProgress = _progress  
end


;+
; Reset the animator.
;-
pro visgrtranslateanimator::reset
  compile_opt strictarr
  
  self.currentProgress = 0.0
end


;+
; Create a translate animator.
;
; :Returns:
;    1 for success, 0 for failure
;
; :Keywords:
;    translation : in, optional, type=fltarr(3)
;       amount to translate each dimension
;    _extra : in, optional, type=keywords
;       keyword to VISgrAnimator::init
;-
function visgrtranslateanimator::init, translation=translation, _extra=e
  compile_opt strictarr

  if (~self->visgranimator::init(_extra=e)) then return, 0
  
  self.translation = n_elements(translation) eq 0L ? fltarr(3) + 1.0 : translation
  self.currentProgress = 0.0
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    translation
;       direction to translate
;    currentProgress
;       amount of progress in the animation
;-
pro visgrtranslateanimator__define
  compile_opt strictarr

  define = { VISgrTranslateAnimator, inherits VISgrAnimator, $
             translation: fltarr(3), $  
             currentProgress: 0.0 $
           }
end

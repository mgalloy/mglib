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

  t = mg_expm((_progress - self.currentProgress) * mg_alogm(self.transform))
  self.target->getProperty, transform=orig_t
  self.target->setProperty, transform=orig_t # t

  self.currentProgress = _progress
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
;    transform
;       amount to scale each dimension
;-
pro mggrtransformanimator__define
  compile_opt strictarr

  define = { MGgrTransformAnimator, inherits MGgrAnimator, $
             transform: fltarr(4, 4) $
           }
end
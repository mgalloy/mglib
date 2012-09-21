;+
; Get properties of the animator.
;
; @keyword nframes {out}{optional}{type=long} number of frames in the animator
; @keyword _ref_extra {out}{optional}{type=keywords} keywords to
;          MGgrAnimator::getProperty 
;-
pro mggrtransformanimator::getProperty, nframes=nframes, _ref_extra=e
  compile_opt strictarr

  if (arg_present(nframes)) then nframes = self.transforms->count()
  if (n_elements(e) gt 0) then self->mggranimator::getProperty, _extra=e
end


;+
; Add another step of the animation for this animator.
; 
; @param x {in}{required}{type=float} amount to translate target in x-direction
; @param y {in}{required}{type=float} amount to translate target in y-direction
; @param z {in}{required}{type=float} amount to translate target in z-direction
;-
pro mggrtransformanimator::addTranslate, x, y, z
  compile_opt strictarr

  self.model->reset
  self.model->translate, x, y, z
  self.model->getProperty, transform=transform

  self->addTransform, transform
end


;+
; Add another step of the animation for this animator.
; 
; @param sx {in}{required}{type=float} amount to scale target in x-direction
; @param sy {in}{required}{type=float} amount to scale target in y-direction
; @param sz {in}{required}{type=float} amount to scale target in z-direction
;-
pro mggrtransformanimator::addScale, sx, sy, sz
  compile_opt strictarr

  self.model->reset
  self.model->scale, sx, sy, sz
  self.model->getProperty, transform=transform

  self->addTransform, transform
end


;+
; Add another step of the animation for this animator.
; 
; @param axis {in}{required}{type=fltarr(3)} axis to rotate about
; @param angle {in}{required}{type=float} angle to rotate about axis
;-
pro mggrtransformanimator::addRotate, axis, angle
  compile_opt strictarr

  self.model->reset
  self.model->rotate, axis, angle
  self.model->getProperty, transform=transform

  self->addTransform, transform
end


;+
; Add another step of the animation for this animator.
; 
; @param transform {in}{required}{type=fltarr(4, 4)} transformation matrix
;        representing a step in the animation
;-
pro mggrtransformanimator::addTransform, transform
  compile_opt strictarr

  otransform = obj_new('MGgrTransform', transform)
  self.transforms->add, otransform
end


;+
; Apply the animator to the target for a given frame.
;
; @keyword frame {in}{required}{type=long} frame number to apply
;-
pro mggrtransformanimator::apply, frame=frame
  compile_opt strictarr

  index = frame - self.startFrame
  if ((index ge self.transforms->count()) or (index lt 0)) then return

  otransform = self.transforms->get(position=index)
  otransform->apply, self.target
end


;+
; Free resources.
;-
pro mggrtransformanimator::cleanup
  compile_opt strictarr

  obj_destroy, [self.model, self.transforms]
  self->mggranimator::cleanup
end


;+
; Initialize object.
;
; @returns 1 for success, 0 otherwise
; @keyword _extra {in}{optional}{type=keywords} keywords of MGgrAnimator::init
;-
function mggrtransformanimator::init, _extra=e
  compile_opt strictarr

  if (~self->mggranimator::init(_extra=e)) then return, 0

  self.model = obj_new('IDLgrModel')
  self.transforms = obj_new('IDL_Container')

  return, 1
end


;+
; Define member variables.
;
; @file_comments A MGgrTransformAnimator represents transforms of a given model 
;                during certain steps in an animation.
; @field model IDLgrModel used for calculations
; @field transforms list of MGgrTransform objects
;-
pro mggrtransformanimator__define
  compile_opt strictarr

  define = { MGgrTransformAnimator, inherits MGgrAnimator, $
             model : obj_new(), $
             transforms : obj_new() $
           }
end

;+
; Get properties of the animator.
;
; @keyword nframes {out}{optional}{type=long} number of frames in the animator
; @keyword _ref_extra {out}{optional}{type=keyword} keywords to
;          MGgrAnimator::getProperty
;-
pro mggrpropertyanimator::getProperty, nframes=nframes, _ref_extra=e
  compile_opt strictarr

  if (arg_present(nframes)) then nframes = self.properties->count()
  if (n_elements(e) gt 0) then self->mggranimator::getProperty, _extra=e
end


;+
; Add a property name/value to the animator.
; 
; @param name {in}{required}{type=string} name of the property
; @param value {in}{required}{type=any} value of the property
;-
pro mggrpropertyanimator::addProperty, name, value
  compile_opt strictarr

  oproperty = obj_new('MGgrProperty', name, value)
  self.properties->add, oproperty
end


;+
; Apply the animator to the target for a given frame.
;
; @keyword frame {in}{required}{type=long} frame number to apply
;-
pro mggrpropertyanimator::apply, frame=frame
  compile_opt strictarr

  index = frame - self.startFrame
  if ((index ge self.properties->count()) or (index lt 0)) then return

  oproperty = self.properties->get(position=index)
  oproperty->apply, self.target
end


;+
; Free resources.
;-
pro mggrpropertyanimator::cleanup
  compile_opt strictarr

  obj_destroy, self.properties
  self->mggranimator::cleanup
end


;+
; Initialize the object.
;
; @returns 1 for success, 0 otherwise
; @keyword _extra {in}{optional}{type=keywords} keywords to MGgrAnimator::init
;-
function mggrpropertyanimator::init, _extra=e
  compile_opt strictarr

  if (~self->mggranimator::init(_extra=e)) then return, 0

  self.properties = obj_new('IDL_Container')

  return, 1
end


;+
; Define member variables.
;
; @file_comments This class represents changes to the property values of a given
;                target object in an animation.
; @field properties IDL_Container holding properties
;-
pro mggrpropertyanimator__define
  compile_opt strictarr

  define = { MGgrPropertyAnimator, inherits MGgrAnimator, $
             properties : obj_new() $
           }
end

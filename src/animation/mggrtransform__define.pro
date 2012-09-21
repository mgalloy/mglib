;+
; Apply transformation matrix to given model.
; 
; @param model {in}{required}{type=object} IDLgrModel to apply transform to
;-
pro mggrtransform::apply, model
  compile_opt strictarr

  model->getProperty, transform=t
  model->setProperty, transform=t # self.transform
end


;+
; Initialize object.
;
; @returns 1 for success, 0 for otherwise
; @param transform {in}{required}{type=fltarr(4, 4)} transformation matrix to store
;-
function mggrtransform::init, transform
  compile_opt strictarr

  self.transform = transform

  return, 1
end


;+
; Define member variables.
; 
; @file_comments A Mggrtransform represents a transformation matrix.
; @field transform a transformation matrix
;-
pro mggrtransform__define
  compile_opt strictarr

  define = { MGgrTransform, transform : fltarr(4, 4) }
end

;+
; Compute a transformation representing a scaling.
;
; @returns fltarr(4, 4)
; @param sx {in}{required}{type=float} amount to scale target in x-direction
; @param sy {in}{required}{type=float} amount to scale target in y-direction
; @param sz {in}{required}{type=float} amount to scale target in z-direction
;-
function mg_scale, sx, sy, sz
  compile_opt strictarr

  omodel = obj_new('IDLgrModel')
  omodel->scale, sx, sy, sz
  omodel->getProperty, transform=t
  obj_destroy, omodel
  return, t
end

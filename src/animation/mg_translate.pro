;+
; Compute a transformation matrix representing a translation.
;
; @returns fltarr(4, 4)
; @param x {in}{required}{type=float} amount to translate target in x-direction
; @param y {in}{required}{type=float} amount to translate target in y-direction
; @param z {in}{required}{type=float} amount to translate target in z-direction
;-
function mg_translate, x, y, z
  compile_opt strictarr

  omodel = obj_new('IDLgrModel')
  omodel->translate, x, y, z
  omodel->getProperty, transform=t
  obj_destroy, omodel
  return, t
end

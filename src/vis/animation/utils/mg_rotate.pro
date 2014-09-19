; docformat = 'rst'

;+
; Computes a transformation matrix representing a rotation.
;
; :Returns:
;   `fltarr(4, 4)`
;
; :Params:
;   axis : in, required, type=fltarr(3)
;     axis to rotate about
;   angle : in, required, type=float
;     angle to rotate about axis
;-
function mg_rotate, axis, angle
  compile_opt strictarr

  omodel = obj_new('IDLgrModel')
  omodel->rotate, axis, angle
  omodel->getProperty, transform=t
  obj_destroy, omodel
  return, t
end

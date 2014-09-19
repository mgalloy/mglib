; docformat = 'rst'

;+
; Compute a transformation matrix representing a translation.
;
; :Returns:
;   `fltarr(4, 4)`
;
; :Params:
;   x : in, required, type=float
;     amount to translate target in x-direction
;   y : in, required, type=float
;     amount to translate target in y-direction
;   z : in, required, type=float
;     amount to translate target in z-direction
;-
function mg_translate, x, y, z
  compile_opt strictarr

  omodel = obj_new('IDLgrModel')
  omodel->translate, x, y, z
  omodel->getProperty, transform=t
  obj_destroy, omodel
  return, t
end

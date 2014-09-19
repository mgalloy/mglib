; docformat = 'rst'

;+
; Compute a transformation representing a scaling.
;
; :Returns:
;   `fltarr(4, 4)`
;
; :Params:
;   sx : in, required, type=float
;     amount to scale target in x-direction
;   sy : in, required, type=float
;     amount to scale target in y-direction
;   sz : in, required, type=float
;     amount to scale target in z-direction
;-
function mg_scale, sx, sy, sz
  compile_opt strictarr

  omodel = obj_new('IDLgrModel')
  omodel->scale, sx, sy, sz
  omodel->getProperty, transform=t
  obj_destroy, omodel
  return, t
end

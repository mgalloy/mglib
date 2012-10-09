; docformat = 'rst'

;+
; Transforms a point by a transformation matrix.
;
; :Categories:
;    object graphics
;
; :Examples:
;    For example, let's rotate a point 90 degrees about the x-axis. The
;    easiest way to specify the transformation matrix is with an IDLgrModel::
;
;       IDL> model = obj_new('IDLgrModel')
;       IDL> model->rotate, [1, 0, 0], 90
;
;    Next, use the model created to transform [0, 1, 0]::
;
;       IDL> print, mg_transformpoint([0, 1, 0], model)
;              0.0000000  -3.8285687e-16       1.0000000
;
;    This example is included as a main-level program at the end of this file
;    and can be run by typing::
;
;       IDL> .run mg_transformpoint
;-

;+
; Transforms a point by a transformation matrix.
;
; :Returns:
;    fltarr(3)
;
; :Params:
;    point : in, required, type=fltarr(3)
;       point in data coordinates
;    ctm : in, required, type="object or fltarr(4, 4)"
;       either a transformation matrix or an object with a getCTM method
;-
function mg_transformpoint, point, ctm
  compile_opt strictarr

  _ctm = size(ctm, /type) eq 11 ? ctm->getCTM() : ctm

  tPoint = _ctm ## [point, 1.0]
  return, reform(tPoint[0:2])
end


; main-level example program

model = obj_new('IDLgrModel')
model->rotate, [1, 0, 0], 90
print, mg_transformpoint([0, 1, 0], model)
obj_destroy, model

end
; docformat = 'rst'

;+
; Example of using the animation classes.
;
; Graphics hierarchy setup
; ------------------------
;
; An object graphics hierarchy is setup in the standard way::
;
;    oview = obj_new('IDLgrView')
;
;    omodel = obj_new('IDLgrModel')
;    oview->add, omodel
;
;    oorb = obj_new('orb', radius=0.9, color=[0, 0, 255])
;    omodel->add, oorb
;
;    olightmodel = obj_new('IDLgrModel')
;    oview->add, olightmodel
;
;    olight = obj_new('IDLgrLight', type=2, location=[1, 1, 1])
;    olightmodel->add, olight
;
;
; Animation hierarchy
; -------------------
;
; A separate animation hierarchy is then built to represent the animations
; intended to run on the object graphics hierarchy. This hierarchy is rooted
; at a `MGgrWindowAnimation` (for interactive animations) or a
; `MGgrImageSequenceAnimation` (for creating a sequence of images):
;
;    oanimation = obj_new('MGgrWindowAnimation', dimension=[400, 400])
;
; There are various other animators that can be children of the root that
; produce transformations, property changes, etc.
;
; Using TransformAnimator to scale and rotate
; -------------------------------------------
;
; A `MGgrTransformAnimator` represents a scaling, rotation, or translation
; transformation. Here we scale `omodel` down and then back up::
;
;    oanimator1 = obj_new('MGgrTransformAnimator', target=omodel)
;    for i = 0, 20 do begin
;      oanimator1->addScale, 0.97, 0.97, 0.97
;    endfor
;    oanimation->addAnimator, oanimator1
;
;    for i = 0, 20 do begin
;      oanimator1->addScale, 1.02, 1.02, 1.02
;    endfor
;
; Then we rotate the `olightmodel`::
;
;    oanimator2 = obj_new('MGgrTransformAnimator', target=olightmodel)
;    for i = 0, 44 do begin
;      oanimator2->addRotate, [0, 1, 0], 8
;    endfor
;    oanimation->addAnimator, oanimator2
;
; Produce the animation
; ---------------------
;
; Finally, the animation is produced with::
;
;    oanimation->draw, oview
;
; :Author:
;    Michael Galloy, 2011
;-

view = obj_new('IDLgrView')

model = obj_new('IDLgrModel')
view->add, model

cowFilename = filepath('cow10.sav', subdir=['examples', 'data'])
restore, cowFilename
colors = randomu(seed, n_elements(x))
vertcolors = rebin(reform(255 * round(colors), 1, n_elements(x)), 3, n_elements(x))

cow = obj_new('IDLgrPolygon', x, y, z, polygons=polylist, $
              color=[150, 100, 20], shading=1)
model->add, cow

lightmodel = obj_new('IDLgrModel')
view->add, lightmodel

light = obj_new('IDLgrLight', type=2, location=[1, 1, 1])
lightmodel->add, light

parallel_animator = obj_new('MGgrParallelAnimator')

seq1_animator = obj_new('MGgrSequenceAnimator')
shrink_animator = obj_new('MGgrScaleAnimator', $
                          target=model, $
                          duration=1.0, $
                          size=[2.0, 2.0, 2.0])
grow_animator = obj_new('MGgrScaleAnimator', $
                        target=model, $
                        duration=1.0, $
                        size=[0.5, 0.5, 0.5])
seq1_animator->add, [shrink_animator, grow_animator]

seq2_animator = obj_new('MGgrSequenceAnimator')
spin1_animator = obj_new('MGgrRotateAnimator', $
                         target=model, $
                         duration=1.0, $
                         angle=360., $
                         axis=[0., 1., 0.])
spin2_animator = obj_new('MGgrRotateAnimator', $
                         target=model, $
                         duration=1.0, $
                         angle=360., $
                         axis=[1., 0., 0.])
seq2_animator->add, [spin1_animator, spin2_animator]

parallel_animator->add, [seq1_animator, seq2_animator]

win = obj_new('IDLgrWindow', dimensions=[400, 400])
animation = obj_new('MGgrAnimation', destination=win, animator=parallel_animator)

animation->draw, view

end

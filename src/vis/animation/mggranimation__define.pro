; docformat = 'rst'

;+
; Destination class for object graphics.
;
; :Properties:
;    destination
;       object graphics destination class to do rendering
;    animator
;       subclass of `MGgrAnimator` to do the animation
;    graphics_tree
;       root of object graphics hierarchy to render
;    frame_rate
;       number of frames per second
;-


;+
; Timer callback routine.
;
; :Params:
;    animation : in, optional, type=object
;       `MGgrAnimation` object to cause to draw a frame
;-
pro mggranimation_timer, animation
  compile_opt strictarr

  animation->_draw
end


;+
; Private draw method that doesn't take any arguments, everything is already
; set up by the regular draw method. This method will be called for each frame
; of the animation.
;
; :private:
;-
pro mggranimation::_draw
  compile_opt strictarr

  self.animator->animate, float(++self.currentFrame) / float(self.totalFrames)
  self.destination->draw, self.picture
end


;+
; Draw object graphic hierarchy.
;
; :Params:
;    picture : in, optional, type=object
;       root of object graphics hierarchy to render: scene, view group, or
;       view
;-
pro mggranimation::draw, picture
  compile_opt strictarr

  self.animator->reset
  self.picture = picture

  self.animator->getProperty, duration=duration
  self.currentFrame = 0L
  self.totalFrames = long(duration * self.frameRate)

  timer = obj_new('MG_Timer', callback='mggranimation_timer', uvalue=self, $
                  duration=1. / self.frameRate, nframes=self.totalFrames)
  timer->start
end


;+
; Free resources of the animation.
;-
pro mggranimation::cleanup
  compile_opt strictarr

  obj_destroy, self.animator
end


;+
; Create animation destination.
;
; :Returns:
;    1 for success, 0 for failure
;
; :Keywords:
;    destination : in, optional, type=object
;       object graphics destination class to do rendering
;    animator : in, optional, type=object
;       subclass of `MGgrAnimator` to do the animation
;    graphics_tree : in, optional, type=object
;       root of object graphics hierarchy to render
;    _extra : in, optional, type=keywords
;       keywords to IDLgrWindow::init
;-
function mggranimation::init, destination=destination, animator=animator, $
                              graphics_tree=graphicsTree, $
                              _extra=e
  compile_opt strictarr

  self.destination = n_elements(destination) gt 0L $
                       ? destination $
                       : obj_new('IDLgrWindow', _extra=e)

  self.animator = n_elements(animator) gt 0L ? animator : obj_new()
  self.frameRate = 24

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    destination
;       object graphics destination class to do rendering
;    animator
;       subclass of `MGgrAnimator` to do the animation
;    graphicsTree
;       root of object graphics hierarchy to render
;-
pro mggranimation__define
  compile_opt strictarr

  define = { MGgrAnimation, $
             destination: obj_new(), $
             animator: obj_new(), $
             graphicsTree: obj_new(), $
             picture: obj_new(), $
             currentFrame: 0L, $
             totalFrames: 0L, $
             frameRate: 0L $
           }
end


; main-level example program

view = obj_new('IDLgrView')

model = obj_new('IDLgrModel')
view->add, model

orb = obj_new('orb', radius=0.1, color=[0, 0, 255])
model->add, orb

lightmodel = obj_new('IDLgrModel')
view->add, lightmodel

light = obj_new('IDLgrLight', type=2, location=[1, 1, 1])
lightmodel->add, light

grow = obj_new('MGgrScaleAnimator', $
               target=model, $
               size=[2.0, 2.0, 2.0])

gotoStart = obj_new('MGgrTranslateAnimator', $
                    target=model, $
                    translation=[-0.75, -0.75, 0.])

translateRight = obj_new('MGgrTranslateAnimator', $
                         target=model, $
                         translation=[1.5, 0., 0.], $
                         easing=obj_new('MGgrCircInOutEasing'))

parallel = obj_new('MGgrParallelAnimator')
parallel->add, gotoStart
parallel->add, translateRight

translateUp = obj_new('MGgrTranslateAnimator', $
                       target=model, $
                       translation=[0., 1.5, 0.], $
                       ;duration=2.0, $
                       easing=obj_new('MGgrCircOutEasing'))

translateLeft = obj_new('MGgrTranslateAnimator', $
                        target=model, $
                        translation=[-1.5, 0., 0.], $
                        easing=obj_new('MGgrBounceOutEasing'))

translateDown = obj_new('MGgrTranslateAnimator', $
                        target=model, $
                        translation=[0., -1.5, 0.])

sequence = obj_new('MGgrSequenceAnimator')
sequence->add, [grow, parallel, translateUp, translateLeft, translateDown]

;win = obj_new('MGgrImageDestination', $
;              basename='im/test', $
;              dimensions=[600, 600], $
;              /show_frame)
win = obj_new('IDLgrWindow', dimensions=[600, 600])
animation = obj_new('MGgrAnimation', destination=win, animator=sequence)

animation->draw, view

end

; docformat = 'rst'

;+
; Example of using animation in a widget program.
;-

;+
; Event handler for all events.
;-
pro mg_widget_animation_example_event, event
  compile_opt strictarr

  widget_control, event.top, get_uvalue=pstate
  uname = widget_info(event.id, /uname)
  
  case uname of
    'animate' : (*pstate).oanimation->draw, (*pstate).oview
  endcase
end


;+
; Cleanup code when widget hierarchy dies.
;-
pro mg_widget_animation_example_cleanup, tlb
  compile_opt strictarr

  widget_control, tlb, get_uvalue=pstate
  obj_destroy, (*pstate).oview
  ptr_free, pstate
end


;+
; Widget creation/setup.
;-
pro mg_widget_animation_example
  compile_opt strictarr

  oview = obj_new('IDLgrView')
  
  omodel = obj_new('IDLgrModel')
  oview->add, omodel
  
  oorb = obj_new('orb', radius=0.9, color=[0, 0, 255])
  omodel->add, oorb

  olightmodel = obj_new('IDLgrModel')
  oview->add, olightmodel
  
  olight = obj_new('IDLgrLight', type=2, location=[1, 1, 1])
  olightmodel->add, olight
  
  tlb = widget_base(title='MGgrWindowAnimation in a draw widget', /column)
  controls = widget_base(tlb, /row, space=0)
  animateButton = widget_button(controls, $
                                value=filepath('spinright.bmp', $
                                               subdir=['resource', 'bitmaps']), $
                                /bitmap, uname='animate')
  draw = widget_draw(tlb, graphics_level=2, class='MGgrWindowAnimation', $
                     xsize=400, ysize=400)
  widget_control, tlb, /realize

  widget_control, draw, get_value=oanimation

  oanimator1 = obj_new('MGgrTransformAnimator', target=omodel)
  oanimation->addAnimator, oanimator1
  for i = 0, 20 do oanimator1->addScale, 0.97, 0.97, 0.97
  for i = 0, 20 do oanimator1->addScale, 1/0.97, 1/0.97, 1/0.97
  
  oanimator2 = obj_new('MGgrTransformAnimator', target=olightmodel)
  oanimation->addAnimator, oanimator2
  for i = 0, 44 do oanimator2->addRotate, [0, 1, 0], 8
  
  oanimation->idlgrwindow::draw, oview

  state = { oview : oview, $
            oanimation : oanimation $
          }
  pstate = ptr_new(state, /no_copy)
  widget_control, tlb, set_uvalue=pstate

  xmanager, 'mg_widget_animation_example', tlb, $
            event_handler='mg_widget_animation_example_event', $
            cleanup='mgwidget_animation_example_cleanup', $
            /no_block
end

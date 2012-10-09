; docformat = 'rst'

;+
; Timer class.
;
; :Examples:
;    See the main-level example program::
;
;       IDL> .run mg_timer__define
;
;    The following creates a timer which will go off 5 times with 1.0 seconds
;    between alarms, and then starts it::
;
;       IDL> timer = obj_new('MG_Timer', duration=1.0, nframes=5, $
;                            callback='print', $
;                            uvalue='Callback routine called')
;       IDL> timer->start
;       IDL>
;       Callback routine called
;       IDL>
;       Callback routine called
;       IDL>
;       Callback routine called
;       IDL>
;       Callback routine called
;       IDL>
;       Callback routine called
;
;    The callback routine specified with the CALLBACK keyword must accept a
;    single positional parameter where the value of the UVALUE property is
;    passed to it.
;
; :Properties:
;    active : type=boolean
;       whether the timer is currently running; read-only, use stop/start
;       methods to change
;    duration : type=float
;       time in seconds between timer going off
;    repeating : type=boolean
;       set to repeat forever
;    current_frame : type=long
;       number of times the timer has already gone off
;    nframes : type=long
;       total number of times the timer should go off; defaults to 1
;    callback : type=string
;       procedure to call when timer goes off; this procedure should accept a
;       single positional parameter which is the value of the UVALUE property
;    uvalue : type=any
;       user-defined value passed to callback routine
;-

;+
; Timer event handler.
;
; :Params:
;    event : in, required, type=structure
;       timer event
;-
pro mg_timer_event, event
  compile_opt strictarr

  ; retrieve timer object
  widget_control, event.top, get_uvalue=timer
  timer->_execute
end


;+
; Called when the timer goes off.
;
; :private:
;-
pro mg_timer::_execute
  compile_opt strictarr

  ; don't call callback if timer stopped
  if (~self.active) then return

  if (self.callback ne '') then call_procedure, self.callback, *self.uvalue

  ; set widget timer if timer still active
  self.active and= self.repeating or ++self.currentFrame lt self.nframes
  if (self.active) then widget_control, self.tlb, timer=self.duration
end


;+
; Get properties.
;-
pro mg_timer::getProperty, active=active, $
                           duration=duration, repeating=repeating, $
                           current_frame=currentFrame, nframes=nframes, $
                           callback=callback, uvalue=uvalue
  compile_opt strictarr

  if (arg_present(active)) then active = self.active

  if (arg_present(duration)) then duration = self.duration
  if (arg_present(repeating)) then repeating = self.repeating
  if (arg_present(currentFrame)) then currentFrame = self.currentFrame
  if (arg_present(nframes)) then nframes = self.nframes
  if (arg_present(callback)) then callback = self.callback
  if (arg_present(uvalue)) then uvalue = *self.uvalue
end


;+
; Set properties.
;-
pro mg_timer::setProperty, duration=duration, repeating=repeating, $
                            current_frame=currentFrame, nframes=nframes, $
                            callback=callback, uvalue=uvalue

  compile_opt strictarr

  if (n_elements(duration) gt 0L) then self.duration = duration
  if (n_elements(repeating) gt 0L) then self.repeating = repeating
  if (n_elements(currentFrame) gt 0L) then self.currentFrame = currentFrame
  if (n_elements(nframes) gt 0L) then self.nframes = nframes
  if (n_elements(callback) gt 0L) then self.callback = callback
  if (n_elements(uvalue) gt 0L) then *self.uvalue = uvalue
end


;+
; Start the timer.
;-
pro mg_timer::start
  compile_opt strictarr

  self.active = 1B
  self.currentFrame = 0L

  ; don't even start the timer if it shouldn't ever go off
  if (~self.repeating && self.nframes eq 0L) then return

  widget_control, self.tlb, timer=self.duration
end


;+
; Stop the timer.
;-
pro mg_timer::stop
  compile_opt strictarr

  self.active = 0B
end


;+
; Free resources.
;-
pro mg_timer::cleanup
  compile_opt strictarr

  ptr_free, self.uvalue
end


;+
; Create a timer instance.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mg_timer::init, duration=duration, $
                         repeating=repeating, nframes=nframes, $
                         callback=callback, uvalue=uvalue
  compile_opt strictarr

  self.tlb = widget_base(uvalue=self, map=0)
  widget_control, self.tlb, /realize

  self.duration = n_elements(duration) eq 0L ? 1.0 : duration

  self.repeating = keyword_set(repeating)
  self.nframes = n_elements(nframes) eq 0L ? 1L : nframes

  self.callback = n_elements(callback) eq 0L ? '' : callback
  self.uvalue = ptr_new(uvalue)

  xmanager, 'mg_timer', self.tlb, /no_block

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    tlb
;       hidden top-level base generating timer events
;    active
;       whether the timer is currently running
;    duration
;       time in seconds until timer goes off
;    repeating
;       set to repeat
;    nframes
;       total number of times the timer should go off
;    currentFrame
;       number of times the timer has already gone off
;    callback
;       procedure to call when timer goes off
;    uvalue
;       user-defined value passed to callback routine
;-
pro mg_timer__define
  compile_opt strictarr

  define = { MG_Timer, $
             tlb: 0L, $
             active: 0B, $
             duration: 0.0, $
             currentFrame: 0L, $
             nframes: 0L, $
             repeating: 0B, $
             callback: '', $
             uvalue: ptr_new() $
           }
end


; main-level example program

timer = obj_new('MG_Timer', duration=1.0, nframes=5, $
                callback='print', uvalue='Callback routine called')

timer->start

end

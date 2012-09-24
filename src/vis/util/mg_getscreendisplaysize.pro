; docformat = 'rst'

;+
; Returns the "usable for display" size of the screen, i.e., excluding the
; Windows taskbar or Mac OS X menu.
;
; :Returns:
;    lonarr(2)
;
; :Params:
;    monitor_index : in, optional, type=long, default=primary monitor index
;       index of monitor to return size of
;-
function mg_getscreendisplaysize, monitor_index
  compile_opt strictarr

  monitor_info = obj_new('IDLsysMonitorInfo')
  
  _monitor_index = n_elements(monitor_index) eq 0L $
    ? monitor_info->getPrimaryMonitorIndex() $
    : monitor_index
    
  rects = monitor_info->getRectangles(/exclude_taskbar)
  
  obj_destroy, monitor_info
  
  return, rects[2:3 , _monitor_index]
end

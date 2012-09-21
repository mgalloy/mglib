; docformat = 'rst'

;+
; Validation tool for tests easing functions. Creates a simple plot of an
; easing function.
;
; :Params:
;    easing : in, optional, type=string
;       classname of VISgrEasing subclass to check
;-
pro vis_checkeasing, easing
  compile_opt strictarr

  n = 1000L
  t = findgen(n) / (n - 1L)
  p = fltarr(n)
  
  e = obj_new(easing)
  
  for i = 0L, n - 1L do p[i] = e->ease(t[i])
  
  window, title='Easing function: ' + easing, /free, xsize=400, ysize=400
  plot, t, p
  
  obj_destroy, e
end

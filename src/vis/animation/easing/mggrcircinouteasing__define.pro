; docformat = 'rst'

;+
; Circular Easing class. Provides a simple acceleration between two animator
; states.
;-

;+
; Do a circular easing (accelerates).
;
; :Returns:
;    the correct value
;
; :Params:
;    t : in, required, type=float
;      animation progress, 0 to 1.
;-
function mggrcircinouteasing::ease, t
  compile_opt strictarr


  return, t lt 0.5 ? 0.5 - sqrt(0.25 - t * t) : 0.5 + sqrt(0.25 - (t - 1.) * (t - 1.))
end


;+
; Define instance variables.
;-
pro mggrcircinouteasing__define
  compile_opt strictarr

  define = { MGgrCircInOutEasing, inherits MGgrEasing }
end
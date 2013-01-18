; docformat = 'rst'

;+
; Base Easing class. Provides a simple linear transition between two animator
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
function mggrcircouteasing::ease, t
  compile_opt strictarr

  return, 1.0 - sqrt(1.0 - t * t); 2. - sqrt(5. - (t + 1.) * (t + 1.)) ;
end


;+
; Define instance variables.
;-
pro mggrcircouteasing__define
  compile_opt strictarr

  define = { MGgrCircOutEasing, inherits MGgrEasing }
end

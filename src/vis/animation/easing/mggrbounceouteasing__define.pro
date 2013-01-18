; docformat = 'rst'

;+
; Bounce Easing class. Provides a bouncing transition between two animator
; states.
;-

;+
; Do a bouncing easing at the end.
;
; :Returns:
;    the correct value
;
; :Params:
;    t : in, required, type=float
;      animation progress, 0 to 1.
;-
function mggrbounceouteasing::ease, t
  compile_opt strictarr

  return, 1. - (1. - sqrt(t > 0)) ^ 2 * abs(sin(4. * t * !pi + !pi / 2.))
end


;+
; Define instance variables.
;-
pro mggrbounceouteasing__define
  compile_opt strictarr

  define = { MGgrBounceOutEasing, inherits MGgrEasing }
end

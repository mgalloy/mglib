; docformat = 'rst'

;+
; Base Easing class. Provides a simple linear transition between two animator
; states.
;-

;+
; Do the easing. Default is linear transition.
;
; :Returns:
;    the correct value
;
; :Params:
;    t : in, required, type=float
;      animation progress, 0 to 1.
;-
function mggreasing::ease, t
  compile_opt strictarr

  return, t
end


;+
; Define instance variables.
;
; :Fields:
;    _dummy
;       required to have at least one instance variable
;-
pro mggreasing__define
  compile_opt strictarr

  define = { MGgrEasing, _dummy: 0B }
end

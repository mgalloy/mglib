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
function visgreasing::ease, t
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
pro visgreasing__define
  compile_opt strictarr
  
  define = { VISgrEasing, _dummy: 0B }
end
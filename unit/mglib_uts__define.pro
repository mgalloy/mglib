; docformat = 'rst'

;+
; Initialize object, adding all test cases.
; 
; :Returns: 
;    1 for success, 0 for failure
;
; :Keywords: 
;    _extra : in, optional, type=keywords
;       keywords to MGutTestSuite::init
;-
function mglib_uts::init, _extra=e
  compile_opt strictarr

  if (~self->mguttestsuite::init(_strict_extra=e)) then return, 0

  self->add, /all

  return, 1
end


;+
; Define member variables.
;-
pro mglib_uts__define
  compile_opt strictarr

  define = { mglib_uts, inherits MGutTestSuite }
end

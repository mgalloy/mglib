; docformat = 'rst'

;+
; Test suite containing all unit tests for the vis library.
;-

;+
; Create full test suite for vis library.
; 
; :Keywords:
;    _ref_extra : in, out, optional, type=keyword
;       keywords to MGutTestSuite::init
;-
function visutalltests_uts::init, _ref_extra=e
  compile_opt strictarr
  
  if (~self->mguttestsuite::init(_strict_extra=e)) then return, 0
  
  self->add, /all
  
  return, 1
end


pro visutalltests_uts__define
  compile_opt strictarr
  
  define = { VISutAllTests_uts, inherits MGutTestSuite }
end

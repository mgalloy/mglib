; docformat = 'rst'

;+
; Compares each item in a list of versions to all items in the list.
;-
function mg_src_root_ut::test_basic
  compile_opt strictarr

  root = mg_src_root()
  assert, file_test(filepath('mg_src_root_ut__define.pro', root=root)), $
          'mg_src_root_ut__define.pro not found'

  return, 1
end


function mg_src_root_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_src_root', /is_function

  return, 1
end


;+
; Define member variables.
;-
pro mg_src_root_ut__define
	compile_opt strictarr

	define = { mg_src_root_ut, inherits MGutLibTestCase }
end

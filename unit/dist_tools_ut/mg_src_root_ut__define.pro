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


;+
; Define member variables.
;-
pro mg_src_root_ut__define
	compile_opt strictarr

	define = { mg_src_root_ut, inherits MGutLibTestCase }
end
; docformat = 'rst'

function mg_check_path_ut::test_basic
  compile_opt strictarr

  root = mg_src_root()
  cdir = filepath('', root=root)
  assert, mg_check_path(cdir), 'current directory not found'

  return, 1
end


function mg_check_path_ut::test_unknown_file
  compile_opt strictarr

  root = mg_src_root()

  unknown_file = filepath('unknown.dat', root=root)
  unknown_file_status = mg_check_path(unknown_file, partial_path=unknown_file_ppath)
  assert, ~unknown_file_status, 'unknown file found'
  assert, unknown_file_ppath eq unknown_file, $
          'unknown file partial path not correct: %s', $
          unknown_file_ppath

  return, 1
end


function mg_check_path_ut::test_unknown_path
  compile_opt strictarr

  root = mg_src_root()

  unknown_path = filepath('unknown.dat', subdir=['unknown1', 'unknown2'], root=root)
  unknown_path_status = mg_check_path(unknown_path, partial_path=unknown_path_ppath)
  assert, ~unknown_path_status, 'unknown path found'
  assert, unknown_path_ppath eq filepath('unknown1', root=root), $
          'unknown path partial path not correct: %s', $
          unknown_path_ppath

  return, 1
end


;+
; Test `MG_CHECK_PATH`.
;-
pro mg_check_path_ut__define
  compile_opt strictarr

  define = { mg_check_path_ut, inherits MGutLibTestCase }
end

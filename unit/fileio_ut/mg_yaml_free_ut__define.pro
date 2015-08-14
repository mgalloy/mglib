; docformat = 'rst'

function mg_yaml_free_ut::test_objects
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  o = list(hash('a', 1, 'b', 2), hash('c', 3, 'd', 4), list(1, 2, 3))
  mg_yaml_free, o

  return, 1
end


function mg_yaml_free_ut::test_arrays
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  o = [hash('a', 1, 'b', 2), hash('c', 3, 'd', 4), list(1, 2, 3)]
  mg_yaml_free, o

  return, 1
end


function mg_yaml_free_ut::test_structs
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  o = { a: hash('a', 1, 'b', 2), b: hash('c', 3, 'd', 4), c: list(1, 2, 3) }
  mg_yaml_free, o

  return, 1
end


function mg_yaml_free_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mg_yaml_free']

  return, 1
end



;+
; Test `MG_READ_CONFIG`.
;-
pro mg_yaml_free_ut__define
  compile_opt strictarr

  define = { mg_yaml_free_ut, inherits MGutLibTestCase }
end

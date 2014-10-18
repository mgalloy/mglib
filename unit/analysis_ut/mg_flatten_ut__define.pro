function mg_flatten_ut::test_basic
  compile_opt strictarr

  x = findgen(2, 3, 5)

  result = mg_flatten(x)
  standard = findgen(2 * 3 * 5)

  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_flatten_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_flatten', /is_function

  return, 1
end


pro mg_flatten_ut__define
  compile_opt strictarr

  define = { mg_flatten_ut, inherits MGutLibTestCase }
end

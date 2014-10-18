function mg_repeat_ut::test_basic
  compile_opt strictarr

  result = mg_repeat(findgen(5), 3)
  standard = [findgen(5), findgen(5), findgen(5)]
  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_repeat_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_repeat', /is_function

  return, 1
end


pro mg_repeat_ut__define
  compile_opt strictarr

  define = { mg_repeat_ut, inherits MGutLibTestCase }
end

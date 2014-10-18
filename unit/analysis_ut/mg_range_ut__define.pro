function mg_range_ut::test_basic
  compile_opt strictarr

  d = [0, -1, 2, -3, 4, -1, 2]
  result = mg_range(d)

  assert, array_equal(result, [-3, 4]), 'incorrect result: %d', result

  return, 1
end


function mg_range_ut::test_same
  compile_opt strictarr

  d = fltarr(100) + 1.3
  result = mg_range(d)

  assert, array_equal(result, [1.3, 1.3]), 'incorrect result: %d', result

  return, 1
end


function mg_range_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_range', /is_function

  return, 1
end


pro mg_range_ut__define
  compile_opt strictarr

  define = { mg_range_ut, inherits MGutLibTestCase }
end

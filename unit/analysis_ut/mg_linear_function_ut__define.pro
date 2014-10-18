;+
; Basic tests.
;-
function mg_linear_function_ut::test_basic
  compile_opt strictarr

  xc = mg_linear_function([1, 2], [0, 1])
  assert, array_equal(xc, [-1., 1.]), 'incorrect function'

  xc = mg_linear_function([1, 5], [2, 3])
  assert, array_equal(xc, [1.75, 0.25]), 'incorrect function'

  return, 1
end


function mg_linear_function_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_linear_function', /is_function

  return, 1
end


pro mg_linear_function_ut__define
  compile_opt strictarr

  define = { mg_linear_function_ut, inherits MGutLibTestCase }
end

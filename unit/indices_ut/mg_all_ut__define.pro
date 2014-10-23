; docformat = 'rst'

function mg_all_ut::test_basic
  compile_opt strictarr

  n1 = long(randomu(0, 5) * 10)
  n2 = long(randomu(4, 5) * 10)

  result1 = mg_all(n1 mod 2)
  result2 = mg_all(n2 mod 2)

  assert, ~result1, 'incorrect result1'
  assert, result2, 'incorrect result2'

  return, 1
end


function mg_all_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_all', /is_function

  return, 1
end


pro mg_all_ut__define
  compile_opt strictarr

  define = { mg_all_ut, inherits MGutLibTestCase }
end

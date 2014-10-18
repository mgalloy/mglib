function mg_power2_ut::test_powersof2
  compile_opt strictarr

  for i = 0, 63 do begin
    x = 2ULL^i
    result = mg_power2(x)
    assert, result eq x, 'incorrect result: %d', result
  end

  return, 1
end


function mg_power2_ut::test_powersof2minus1
  compile_opt strictarr

  for i = 2, 63 do begin
    x = 2ULL^i
    result = mg_power2(x - 1ULL)
    assert, result eq x, 'incorrect result: %d', result
  end

  return, 1
end


function mg_power2_ut::test2
  compile_opt strictarr

  x = 3
  standard = 4

  result = mg_power2(x)
  assert, result eq standard, 'incorrect result: %d', result

  return, 1
end


function mg_power2_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_power2', /is_function

  return, 1
end


pro mg_power2_ut__define
  compile_opt strictarr

  define = { mg_power2_ut, inherits MGutLibTestCase }
end

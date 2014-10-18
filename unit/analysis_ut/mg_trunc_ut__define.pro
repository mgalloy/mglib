function mg_trunc_ut::test_array
  compile_opt strictarr

  x = [0., 1.5, -1.5, 2.25, -2.25]
  standard = [0., 1., -1., 2., -2.]

  result = mg_trunc(x)
  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_trunc_ut::test_elements
  compile_opt strictarr

  x = [0., 1.5, -1.5, 2.25, -2.25]
  standard = [0., 1., -1., 2., -2.]

  for i = 0L, n_elements(x) - 1L do begin
    result = mg_trunc(x[i])
    assert, result eq standard[i], 'incorrect result for element %d', i
  endfor

  return, 1
end


function mg_trunc_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_trunc', /is_function

  return, 1
end


pro mg_trunc_ut__define
  compile_opt strictarr

  define = { mg_trunc_ut, inherits MGutLibTestCase }
end

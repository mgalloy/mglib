function mg_sort_ut::test1
  compile_opt strictarr

  n = 10L
  x = [findgen(n), fltarr(10) + n - 1., findgen(n) + n]
  result = mg_sort(x)
  standard = lindgen(3 * n)

  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_sort_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_sort', /is_function

  return, 1
end


pro mg_sort_ut__define
  compile_opt strictarr

  define = { mg_sort_ut, inherits MGutLibTestCase }
end

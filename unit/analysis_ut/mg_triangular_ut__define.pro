function mg_triangular_ut::test_upper
  compile_opt strictarr

  d = findgen(5, 5)
  result = mg_triangular(d, /upper)
  standard = [[0.0, 1.0, 2.0, 3.00, 4.0], $
              [0.0, 6.0, 7.0, 8.00, 9.0], $
              [0.0, 0.0, 12.0, 13.0, 14.0], $
              [0.0, 0.0, 0.0, 18.0, 19.0], $
              [0.0, 0.0, 0.0, 0.00, 24.0]]

  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_triangular_ut::test_upper_strict
  compile_opt strictarr

  d = findgen(5, 5)
  result = mg_triangular(d, /upper, /strict)
  standard = [[0.0, 1.0, 2.0, 3.00, 4.0], $
              [0.0, 0.0, 7.0, 8.00, 9.0], $
              [0.0, 0.0, 0.0, 13.0, 14.0], $
              [0.0, 0.0, 0.0, 0.0, 19.0], $
              [0.0, 0.0, 0.0, 0.00, 0.0]]

  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_triangular_ut::test_lower
  compile_opt strictarr

  d = findgen(5, 5)
  result = mg_triangular(d, /lower)
  standard = [[0.0, 0.0, 0.0, 0.00, 0.0], $
              [5.0, 6.0, 0.0, 0.00, 0.0], $
              [10.0, 11.0, 12.0, 0.0, 0.0], $
              [15.0, 16.0, 17.0, 18.0, 0.0], $
              [20.0, 21.0, 22.0, 23.00, 24.0]]

  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_triangular_ut::test_lower_strict
  compile_opt strictarr

  d = findgen(5, 5)
  result = mg_triangular(d, /lower, /strict)
  standard = [[0.0, 0.0, 0.0, 0.00, 0.0], $
              [5.0, 0.0, 0.0, 0.00, 0.0], $
              [10.0, 11.0, 0.0, 0.0, 0.0], $
              [15.0, 16.0, 17.0, 0.0, 0.0], $
              [20.0, 21.0, 22.0, 23.00, 0.0]]

  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_triangular_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_triangular', /is_function

  return, 1
end


pro mg_triangular_ut__define
  compile_opt strictarr

  define = { mg_triangular_ut, inherits MGutLibTestCase }
end

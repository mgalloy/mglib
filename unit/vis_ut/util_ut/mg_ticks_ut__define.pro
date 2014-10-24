function mg_ticks_ut::test_basic
  compile_opt strictarr

  x = [0., 1.0, 2.3, 4.5, 7.6, 8.9, 10.]

  standard_ticks = 4L
  standard_range = [0.0, 10.0]
  standard_tickv = [0.0, 2.5, 5.0, 7.5, 10.0]

  result_ticks = mg_ticks(x, range=result_range, tickv=result_tickv)

  assert, array_equal(result_range, standard_range), $
          'incorrect range: [%s]', strjoin(strtrim(result_range, 2), ', ')
  assert, result_ticks eq standard_ticks, 'incorrect ticks: %d', result_ticks
  assert, array_equal(result_tickv, standard_tickv), $
          'incorrect tick values: [%s]', strjoin(strtrim(result_tickv, 2), ', ')

  return, 1
end


function mg_ticks_ut::test_extend
  compile_opt strictarr

  x = [0.1, 1.0, 2.3, 4.5, 7.6, 8.9, 9.9]

  standard_ticks = 4L
  standard_range = [0.0, 10.0]
  standard_tickv = [0.0, 2.5, 5.0, 7.5, 10.0]

  result_ticks = mg_ticks(x, range=result_range, tickv=result_tickv)

  assert, array_equal(result_range, standard_range), $
          'incorrect range: [%s]', strjoin(strtrim(result_range, 2), ', ')
  assert, result_ticks eq standard_ticks, 'incorrect ticks: %d', result_ticks
  assert, array_equal(result_tickv, standard_tickv), $
          'incorrect tick values: [%s]', strjoin(strtrim(result_tickv, 2), ', ')

  return, 1
end


function mg_ticks_ut::test_beyond
  compile_opt strictarr

  x = [0., 1.0, 2.3, 4.5, 7.6, 8.9, 10.1]

  standard_ticks = 5L
  standard_range = [0.0, 10.1]
  standard_tickv = [0.0, 2.5, 5.0, 7.5, 10.0, 12.5]

  result_ticks = mg_ticks(x, range=result_range, tickv=result_tickv)

  assert, array_equal(result_range, standard_range), $
          'incorrect range: [%s]', strjoin(strtrim(result_range, 2), ', ')
  assert, result_ticks eq standard_ticks, 'incorrect ticks: %d', result_ticks
  assert, array_equal(result_tickv, standard_tickv), $
          'incorrect tick values: [%s]', strjoin(strtrim(result_tickv, 2), ', ')

  return, 1
end


function mg_ticks_ut::test_larger
  compile_opt strictarr

  x = [0., 1.0, 2.3, 4.5, 7.6, 8.9, 100.]

  standard_ticks = 4L
  standard_range = [0.0, 100.]
  standard_tickv = [0.0, 25., 50., 75., 100.]

  result_ticks = mg_ticks(x, range=result_range, tickv=result_tickv)

  assert, array_equal(result_range, standard_range), $
          'incorrect range: [%s]', strjoin(strtrim(result_range, 2), ', ')
  assert, result_ticks eq standard_ticks, 'incorrect ticks: %d', result_ticks
  assert, array_equal(result_tickv, standard_tickv), $
          'incorrect tick values: [%s]', strjoin(strtrim(result_tickv, 2), ', ')

  return, 1
end


function mg_ticks_ut::test_degrees
  compile_opt strictarr

  x = [0.1, 134.8]

  standard_ticks = 3L
  standard_range = [0.0, 135.]
  standard_tickv = [0.0, 45., 90., 135.]

  result_ticks = mg_ticks(x, range=result_range, tickv=result_tickv, /degrees)

  assert, array_equal(result_range, standard_range), $
          'incorrect range: [%s]', strjoin(strtrim(result_range, 2), ', ')
  assert, result_ticks eq standard_ticks, 'incorrect ticks: %d', result_ticks
  assert, array_equal(result_tickv, standard_tickv), $
          'incorrect tick values: [%s]', strjoin(strtrim(result_tickv, 2), ', ')

  return, 1
end


function mg_ticks_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mg_ticks', $
                            'mg_ticks_tickinc', $
                            'mg_ticks_increments'], $
                           /is_function

  return, 1
end


pro mg_ticks_ut__define
  compile_opt strictarr

  define = { mg_ticks_ut, inherits MGutLibTestCase }
end

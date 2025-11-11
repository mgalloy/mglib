; docformat = 'rst'

function mg_repeat_counts_ut::test_basic
  compile_opt strictarr

  x = [100.0, 200.0, 300.0, 400.0]
  counts = [3, 1, 2, 1]

  result = mg_repeat_counts(x, counts)
  standard = [100.0, 100.0, 100.0, 200.0, 300.0, 300.0, 400.0]
  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_repeat_counts_ut::test_zero_start
  compile_opt strictarr

  x = [100.0, 200.0, 300.0, 400.0]
  counts = [0, 3, 1, 2]

  result = mg_repeat_counts(x, counts)
  standard = [200.0, 200.0, 200.0, 300.0, 400.0, 400.0]
  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_repeat_counts_ut::test_zero_mid
  compile_opt strictarr

  x = [100.0, 200.0, 300.0, 400.0]
  counts = [3, 0, 1, 2]

  result = mg_repeat_counts(x, counts)
  standard = [100.0, 100.0, 100.0, 300.0, 400.0, 400.0]
  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_repeat_counts_ut::test_zero_end
  compile_opt strictarr

  x = [100.0, 200.0, 300.0, 400.0]
  counts = [3, 1, 2, 0]

  result = mg_repeat_counts(x, counts)
  standard = [100.0, 100.0, 100.0, 200.0, 300.0, 300.0]
  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_repeat_counts_ut::test_error
  compile_opt strictarr
  @error_is_pass

  x = [100.0, 200.0, 300.0, 400.0]
  counts = [3, 1, 2]

  result = mg_repeat_counts(x, counts)

  return, 1
end


function mg_repeat_counts_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['mg_repeat_counts'], $
                           /is_function

  return, 1
end


pro mg_repeat_counts_ut__define
  compile_opt strictarr

  define = {mg_repeat_counts_ut, inherits MGutLibTestCase}
end

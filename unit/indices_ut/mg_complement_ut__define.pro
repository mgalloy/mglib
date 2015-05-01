; docformat = 'rst'

function mg_complement_ut::test_basic
  compile_opt strictarr

  result = mg_complement([0, 2, 5], 6, count=count)
  standard = [1, 3, 4]

  assert, count eq n_elements(standard), $
          'wrong number of elements in complement: %d', count
  assert, array_equal(result, standard), 'incorrect result: %s', $
          strjoin(strtrim(result, 2), ', ')

  return, 1
end


function mg_complement_ut::test_invalidindices
  compile_opt strictarr

  result = mg_complement([0, 2, 7, -1], 6, count=count)
  standard = [1, 3, 4, 5]
  
  assert, count eq n_elements(standard), $
          'wrong number of elements in complement: %d', count
  assert, array_equal(result, standard), 'incorrect result: %s', $
          strjoin(strtrim(result, 2), ', ')

  return, 1
end


function mg_complement_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_complement', /is_function

  return, 1
end


pro mg_complement_ut__define
  compile_opt strictarr

  define = { mg_complement_ut, inherits MGutLibTestCase }
end

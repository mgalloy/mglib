; docformat = 'rst'

function mg_any_ut::test_basic
  compile_opt strictarr

  x = randomu(0L, 100)
  result1 = mg_any(x gt 0.5 and x lt 0.52, indices=ind1)
  result2 = mg_any(x gt 0.35 and x lt 0.36, indices=ind2)

  assert, ~result1, 'incorrect result1: %d', result
  assert, ind1 eq -1, $
          'incorrect ind1: %s', strjoin(strtrim(ind1, 2), ',')

  assert, result2, 'incorrect result1: %d', result
  assert, array_equal(ind2, [80, 93]), $
         'incorrect ind2: %s', strjoin(strtrim(ind2, 2), ',')
  return, 1
end


function mg_any_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_any', /is_function

  return, 1
end


pro mg_any_ut__define
  compile_opt strictarr

  define = { mg_any_ut, inherits MGutLibTestCase }
end
;+
; Basic tests.
;-

function mg_round_ut::test_roundTo
  compile_opt strictarr

  r = mg_round([3.5, -1.5, 0., 3., -2., 3.7], 0.1)
  assert, array_equal(r, [3.5, -1.5, 0., 3., -2., 3.7]), 'incorrect value'

  return, 1
end

function mg_round_ut::test_array
  compile_opt strictarr

  r = mg_round([3.5, -1.5, 0., 3., -2., 3.7])
  assert, array_equal(r, [4, -2, 0, 3, -2, 4]), 'incorrect value'

  return, 1
end


function mg_round_ut::test_basic
  compile_opt strictarr

  r = mg_round(3.5)
  assert, r eq 4., 'incorrect value'

  return, 1
end


pro mg_round_ut__define
  compile_opt strictarr

  define = { mg_round_ut, inherits MGutLibTestCase }
end

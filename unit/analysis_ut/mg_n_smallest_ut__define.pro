function mg_n_smallest_ut::test_worstCase
  compile_opt strictarr

  ind = mg_n_smallest([0, 0, 0, 0, 0, 0, 0, 5], 2)
  assert, total(ind eq 7, /preserve_type) eq 0, 'incorrect result'

  return, 1
end


function mg_n_smallest_ut::test_largest
  compile_opt strictarr

  ind = mg_n_smallest([5, 7, 0, 3, 2, 1], 2, /largest)
  assert, array_equal(ind, [1, 0]), 'incorrect result'

  return, 1
end


function mg_n_smallest_ut::test_basic
  compile_opt strictarr

  ind = mg_n_smallest([5, 7, 0, 3, 2, 1], 2)
  assert, array_equal(ind, [2, 5]), 'incorrect result'

  return, 1
end


function mg_n_smallest_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_n_smallest', /is_function

  return, 1
end


;+
; Tests for MG_N_SMALLEST.
;-
pro mg_n_smallest_ut__define
  compile_opt strictarr

  define = { mg_n_smallest_ut, inherits MGutLibTestCase }
end

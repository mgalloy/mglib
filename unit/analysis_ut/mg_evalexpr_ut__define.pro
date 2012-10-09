; docformat = 'rst'

function mg_evalexpr_ut::test_basic
  compile_opt strictarr

  result = mg_evalexpr('1 + 2', error=error)
  assert, error eq 0, 'incorrect error status: %d', error
  assert, result eq 3, 'incorrect result: %d', result

  return, 1
end


function mg_evalexpr_ut::test_subsStruct
  compile_opt strictarr

  result = mg_evalexpr('alpha + beta', { alpha:1, beta:2 }, error=error)
  assert, error eq 0, 'incorrect error status: %d', error
  assert, result eq 3, 'incorrect result: %d', result

  return, 1
end


function mg_evalexpr_ut::test_subsHash
  compile_opt strictarr

  h = hash('alpha', 1, 'beta', 2)
  result = mg_evalexpr('alpha + beta', h, error=error)
  assert, error eq 0, 'incorrect error status: %d', error
  assert, result eq 3, 'incorrect result: %d', result
  obj_destroy, h

  return, 1
end


function mg_evalexpr_ut::test_order1
  compile_opt strictarr

  result = mg_evalexpr('2 + 3*4', error=error)
  assert, error eq 0, 'incorrect error status: %d', error
  assert, result eq 14, 'incorrect result: %d', result

  return, 1
end


function mg_evalexpr_ut::test_order2
  compile_opt strictarr

  result = mg_evalexpr('2 + (3 + 5)*4', error=error)
  assert, error eq 0, 'incorrect error status: %d', error
  assert, result eq 34, 'incorrect result: %d', result

  return, 1
end


function mg_evalexpr_ut::test_order3
  compile_opt strictarr

  result = mg_evalexpr('2^3 * 5 + (2 + 1)^(3 + 1)', error=error)
  assert, error eq 0, 'incorrect error status: %d', error
  assert, result eq 121, 'incorrect result: %d', result

  return, 1
end


function mg_evalexpr_ut::test_function1
  compile_opt strictarr

  result = mg_evalexpr('cos(pi) + exp(2)', { pi: !dpi }, error=error)
  assert, error eq 0, 'incorrect error status: %d', error
  assert, abs(result - (cos(!dpi) + exp(2))) lt 0.001, $
          'incorrect result: %f', result

  return, 1
end


function mg_evalexpr_ut::test_error1
  compile_opt strictarr

  result = mg_evalexpr('1 + + 1', error=error)
  assert, error eq 1, 'incorrect error status: %d', error
  assert, !error_state.msg eq 'MG_EVALEXPR_FACTOR: unexpected operator', $
          'incorrect error status: %s', !error_state.msg

  return, 1
end


pro mg_evalexpr_ut__define
  compile_opt strictarr

  define = { mg_evalexpr_ut, inherits MGutLibTestCase }
end
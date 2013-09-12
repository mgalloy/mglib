function mg_factor_ut::test_prime
  compile_opt strictarr

  result = mg_factor(3)
  assert, array_equal(result, [3]), 'incorrect result: %d', result

  return, 1
end


function mg_factor_ut::test_power
  compile_opt strictarr

  result = mg_factor(8)
  assert, array_equal(result, [2, 2, 2]), 'incorrect result: %d', result

  return, 1
end


function mg_factor_ut::test_twofactors
  compile_opt strictarr

  result = mg_factor(12)
  assert, array_equal(result, [2, 2, 3]), 'incorrect result: %d', result

  return, 1
end


function mg_factor_ut::test_large
  compile_opt strictarr

  result = mg_factor(100)
  assert, array_equal(result, [2, 2, 5, 5]), 'incorrect result: %d', result

  return, 1
end


pro mg_factor_ut__define
  compile_opt strictarr

  define = { mg_factor_ut, inherits MGutLibTestCase }
end

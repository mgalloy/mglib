function mg_gcd_ut::test1
  compile_opt strictarr

  result = mg_gcd(1, 3)
  assert, result, 1, 'incorrect result: %d', result

  return, 1
end


function mg_gcd_ut::test2
  compile_opt strictarr

  result = mg_gcd(6, 3)
  assert, result, 3, 'incorrect result: %d', result

  return, 1
end


function mg_gcd_ut::test3
  compile_opt strictarr

  result = mg_gcd(18, 12)
  assert, result, 6, 'incorrect result: %d', result

  return, 1
end


function mg_gcd_ut::test_zero
  compile_opt strictarr

  result = mg_gcd(8, 0)
  assert, result, 8, 'incorrect result: %d', result

  return, 1
end


pro mg_gcd_ut__define
  compile_opt strictarr

  define = { mg_gcd_ut, inherits MGutLibTestCase }
end

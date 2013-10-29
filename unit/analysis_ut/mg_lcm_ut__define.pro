function mg_lcm_ut::test1
  compile_opt strictarr

  result = mg_lcm(3, 4)
  assert, result eq 12, 'incorrect result: %d', result

  return, 1
end


function mg_lcm_ut::test2
  compile_opt strictarr

  result = mg_lcm(4, 6)
  assert, result eq 12, 'incorrect result: %d', result

  return, 1
end


function mg_lcm_ut::test3
  compile_opt strictarr

  result = mg_lcm(4, 3)
  assert, result eq 12, 'incorrect result: %d', result

  return, 1
end


function mg_lcm_ut::test_zero
  compile_opt strictarr

  result = mg_lcm(6, 4)
  assert, result eq 12, 'incorrect result: %d', result

  return, 1
end


pro mg_lcm_ut__define
  compile_opt strictarr

  define = { mg_lcm_ut, inherits MGutLibTestCase }
end

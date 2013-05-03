function mg_in_ut::test_int
  compile_opt strictarr

  assert, mg_in([0, 1, 3], 1), '1 not in [0, 1, 3]'

  return, 1
end


function mg_in_ut::test_int_not
  compile_opt strictarr

  assert, ~mg_in([0, 1, 3], 2), '2 in [0, 1, 3]'

  return, 1
end


function mg_in_ut::test_string
  compile_opt strictarr

  assert, mg_in(['a', 'b', 'd', 'f'], 'd'), 'd not in [a, b, d, f]'

  return, 1
end


function mg_in_ut::test_string_not
  compile_opt strictarr

  assert, ~mg_in(['a', 'b', 'd', 'f'], 'c'), 'c in [a, b, d, f]'

  return, 1
end


pro mg_in_ut__define
  compile_opt strictarr

  define = { mg_in_ut, inherits MGutLibTestCase }
end

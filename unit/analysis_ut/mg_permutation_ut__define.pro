function mg_permutation_ut::test_choose1
  compile_opt strictarr

  for i = 1, 1000L do begin
    result = mg_permutation(i, 1)
    assert, result eq i, 'incorrect result: %d', result
  endfor

  return, 1
end


function mg_permutation_ut::test_chooseallbut1
  compile_opt strictarr

  f = 1ULL
  for i = 1, 15L do begin
    f *= i
    result = mg_permutation(i, i - 1)
    assert, result eq f, 'incorrect result: %d', result
  endfor

  return, 1
end


function mg_permutation_ut::test1
  compile_opt strictarr

  result = mg_permutation(3, 2)
  assert, result eq 6, 'incorrect result: %d', result

  return, 1
end


pro mg_permutation_ut__define
  compile_opt strictarr

  define = { mg_permutation_ut, inherits MGutLibTestCase }
end

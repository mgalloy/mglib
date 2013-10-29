function mg_choose_ut::test_choose1
  compile_opt strictarr

  for i = 1, 1000L do begin
    result = mg_choose(i, 1)
    assert, result eq i, 'incorrect result: %d', result
  endfor

  return, 1
end


function mg_choose_ut::test_chooseallbut1
  compile_opt strictarr

  for i = 1, 1000L do begin
    result = mg_choose(i, i - 1)
    assert, result eq i, 'incorrect result: %d', result
  endfor

  return, 1
end


function mg_choose_ut::test1
  compile_opt strictarr

  result = mg_choose(3, 2)
  assert, result eq 3, 'incorrect result: %d', result

  return, 1
end


pro mg_choose_ut__define
  compile_opt strictarr

  define = { mg_choose_ut, inherits MGutLibTestCase }
end

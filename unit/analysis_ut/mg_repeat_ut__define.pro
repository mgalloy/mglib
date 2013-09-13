function mg_repeat_ut::test_basic
  compile_opt strictarr

  result = mg_repeat(findgen(5), 3)
  standard = [findgen(5), findgen(5), findgen(5)]
  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


pro mg_repeat_ut__define
  compile_opt strictarr

  define = { mg_repeat_ut, inherits MGutLibTestCase }
end

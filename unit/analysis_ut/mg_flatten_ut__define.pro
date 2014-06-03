function mg_flatten_ut::test_basic
  compile_opt strictarr

  x = findgen(2, 3, 5)

  result = mg_flatten(x)
  standard = findgen(2 * 3 * 5)

  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


pro mg_flatten_ut__define
  compile_opt strictarr

  define = { mg_flatten_ut, inherits MGutLibTestCase }
end

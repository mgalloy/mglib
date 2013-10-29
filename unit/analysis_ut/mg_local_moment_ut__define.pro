function mg_local_moment_ut::test1
  compile_opt strictarr

  x = findgen(10)

  result = mg_local_moment(x, 3)
  standard = [findgen(9), 0.]

  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


pro mg_local_moment_ut__define
  compile_opt strictarr

  define = { mg_local_moment_ut, inherits MGutLibTestCase }
end

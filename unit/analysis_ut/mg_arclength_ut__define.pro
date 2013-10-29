function mg_arclength_ut::test1
  compile_opt strictarr

  x = [0, 1, 1, 0]
  y = [0, 0, 1, 0]

  result = mg_arclength(x, y)
  assert, result eq 2. + sqrt(2), 'incorrect result: %d', result

  return, 1
end


function mg_arclength_ut::test2
  compile_opt strictarr

  x = [0, 1, 1, 0, 0]
  y = [0, 0, 1, 1, 0]

  result = mg_arclength(x, y)
  assert, result eq 4., 'incorrect result: %d', result

  return, 1
end


pro mg_arclength_ut__define
  compile_opt strictarr

  define = { mg_arclength_ut, inherits MGutLibTestCase }
end

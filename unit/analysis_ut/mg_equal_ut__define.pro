function mg_equal_ut::test1
  compile_opt strictarr

  n = 10L
  x = findgen(n)
  y = findgen(n) + 0.01 * (randomu(seed, n) - 0.5)

  assert, ~mg_equal(x, y), 'unequal arrays given as equal'
  assert, mg_equal(x, y, tolerance=0.05), 'arrays should be within tolerance'

  return, 1
end


pro mg_equal_ut__define
  compile_opt strictarr

  define = { mg_equal_ut, inherits MGutLibTestCase }
end

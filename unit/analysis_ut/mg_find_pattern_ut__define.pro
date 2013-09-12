function mg_find_pattern_ut::test1
  compile_opt strictarr

  n = 1000L
  seed = 0L
  d = long(100L * randomu(seed, n))

  result = mg_find_pattern(d, [55, 2, 16, 82, 36])

  assert, result eq 193, 'incorrect result: %d', result

  return, 1
end


pro mg_find_pattern_ut__define
  compile_opt strictarr

  define = { mg_find_pattern_ut, inherits MGutLibTestCase }
end

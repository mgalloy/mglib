function mg_asinh_ut::test1
  compile_opt strictarr

  result = mg_asinh(0.)
  assert, result eq 0., 'incorrect result: %d', result

  return, 1
end


pro mg_asinh_ut__define
  compile_opt strictarr

  define = { mg_asinh_ut, inherits MGutLibTestCase }
end

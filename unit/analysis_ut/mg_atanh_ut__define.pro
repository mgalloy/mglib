function mg_atanh_ut::test1
  compile_opt strictarr

  result = mg_atanh(0.)
  assert, result eq 0., 'incorrect result: %d', result

  return, 1
end


function mg_atanh_ut::test2
  compile_opt strictarr

  result = mg_atanh(complex(0., 1.))
  assert, result eq complex(0., 0.25 * !dpi), 'incorrect result: %d', result

  return, 1
end


pro mg_atanh_ut__define
  compile_opt strictarr

  define = { mg_atanh_ut, inherits MGutLibTestCase }
end

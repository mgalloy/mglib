function mg_sign_ut::test_array
  compile_opt strictarr

  x = [0., 1., -1., 2., -2.]
  standard = [0, 1, -1, 1, -1]

  result = mg_sign(x)
  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_sign_ut::test_elements
  compile_opt strictarr

  x = [0., 1., -1., 2., -2.]
  standard = [0, 1, -1, 1, -1]

  for i = 0L, n_elements(x) - 1L do begin
    result = mg_sign(x[i])
    assert, result eq standard[i], 'incorrect result for element %d', i
  endfor

  return, 1
end


pro mg_sign_ut__define
  compile_opt strictarr

  define = { mg_sign_ut, inherits MGutLibTestCase }
end

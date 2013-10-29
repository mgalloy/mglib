function mg_alogm_ut::test1
  compile_opt strictarr

  seed = 0L
  n = 3L
  x = randomu(seed, n, n)

  result = mg_expm(mg_alogm(x))
  error = total(abs(result - x))
  assert, error lt 0.00001, 'incorrect result, error = %f', error

  return, 1
end


function mg_alogm_ut::test2
  compile_opt strictarr

  seed = 0L
  n = 10L
  x = randomu(seed, n, n)

  result = mg_expm(mg_alogm(x))
  error = total(abs(result - x))
  assert, error lt 0.0001, 'incorrect result, error = %f', error

  return, 1
end


pro mg_alogm_ut__define
  compile_opt strictarr

  define = { mg_alogm_ut, inherits MGutLibTestCase }
end

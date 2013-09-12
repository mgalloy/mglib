function mg_total_ut::test_float_basic
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_ANALYSIS DLM not found', /skip

  result = mg_total(findgen(10))

  assert, size(result, /type) eq 4, 'incorrect type'
  assert, result eq 45., 'incorrect result'

  return, 1
end


function mg_total_ut::test_float_large
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_ANALYSIS DLM not found', /skip

  n = 100000L
  seed = 0L
  d = randomu(seed, n)

  result = mg_total(d)

  assert, size(result, /type) eq 4, 'incorrect type'
  assert, abs(result - 49873.2265625) lt 0.001, 'incorrect result'

  return, 1
end


function mg_total_ut::test_long_basic
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_ANALYSIS DLM not found', /skip

  result = mg_total(lindgen(10))

  assert, size(result, /type) eq 3, 'incorrect type'
  assert, result eq 45L, 'incorrect result'

  return, 1
end


pro mg_total_ut__define
  compile_opt strictarr

  define = { mg_total_ut, inherits MGutLibTestCase }
end

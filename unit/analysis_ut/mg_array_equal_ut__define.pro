function mg_array_equal_ut::test_float1
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_ANALYSIS DLM not found', /skip

  seed = 100L
  n = 20L
  a = randomu(seed, n)
  result = mg_array_equal(a, a)

  assert, result eq 1, 'incorrect result'

  return, 1
end


function mg_array_equal_ut::test_float2
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_ANALYSIS DLM not found', /skip

  seed = 100L
  n = 20L
  a = randomu(seed, n)
  result = mg_array_equal(a, a + 0.1)

  assert, result eq 0, 'incorrect result'

  return, 1
end


function mg_array_equal_ut::test_float_tolerance1
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_ANALYSIS DLM not found', /skip

  seed = 100L
  n = 20L
  a = randomu(seed, n)
  result = mg_array_equal(a, a + 0.1, tolerance=0.2)

  assert, result eq 1, 'incorrect result'

  return, 1
end


function mg_array_equal_ut::test_float_tolerance2
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_ANALYSIS DLM not found', /skip

  seed = 100L
  n = 20L
  a = randomu(seed, n)
  result = mg_array_equal(a, a + 0.1, tolerance=0.05)

  assert, result eq 0, 'incorrect result'

  return, 1
end


function mg_array_equal_ut::test_complex1
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_ANALYSIS DLM not found', /skip

  seed = 100L
  n = 20L
  a = complex(randomu(seed, n), randomu(seed, n))
  result = mg_array_equal(a, a)

  assert, result eq 1, 'incorrect result'

  return, 1
end


function mg_array_equal_ut::test_complex2
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_ANALYSIS DLM not found', /skip

  seed = 100L
  n = 20L
  a = complex(randomu(seed, n), randomu(seed, n))
  result = mg_array_equal(a, a + 0.1)

  assert, result eq 0, 'incorrect result'

  return, 1
end


function mg_array_equal_ut::test_complex_tolerance1
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_ANALYSIS DLM not found', /skip

  seed = 100L
  n = 20L
  a = complex(randomu(seed, n), randomu(seed, n))
  result = mg_array_equal(a, a + 0.1, tolerance=0.2)

  assert, result eq 1, 'incorrect result'

  return, 1
end


function mg_array_equal_ut::test_complex_tolerance2
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_ANALYSIS DLM not found', /skip

  seed = 100L
  n = 20L
  a = complex(randomu(seed, n), randomu(seed, n))
  result = mg_array_equal(a, a + 0.1, tolerance=0.05)

  assert, result eq 0, 'incorrect result'

  return, 1
end


function mg_array_equal_ut::test_no_typeconv
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_ANALYSIS DLM not found', /skip

  seed = 100L
  n = 20L
  a = randomu(seed, n)
  result = mg_array_equal(a, double(a), /no_typeconv)

  assert, result eq 0, 'incorrect result'

  return, 1
end


function mg_array_equal_ut::test_nan1
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_ANALYSIS DLM not found', /skip

  a = [0.0, !values.f_nan, 2.0, 3.0]
  b = [0.0, !values.f_nan, 2.0, 3.0]
  result = mg_array_equal(a, b)
  standard = array_equal(a, b)

  assert, result eq standard, 'incorrect result'

  return, 1
end


function mg_array_equal_ut::test_nan2
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_ANALYSIS DLM not found', /skip

  a = [0.0, !values.f_nan, 2.0, 3.0]
  b = [0.0, !values.f_nan, 2.0, 3.0]
  result = mg_array_equal(a, b, /nan)

  assert, result eq 1, 'incorrect result'

  return, 1
end


; function mg_array_equal_ut::test_typeconversion
;   compile_opt strictarr
;
;   return, 0
; end
;
;
; function mg_array_equal_ut::test_array2scalar
;   compile_opt strictarr
;
;   return, 0
; end


pro mg_array_equal_ut__define
  compile_opt strictarr

  define = { mg_array_equal_ut, inherits MGutLibTestCase }
end

function mg_julian2cf_ut::test_epoch
  compile_opt strictarr

  cf_t = systime(/seconds)
  julian_t = systime(/julian, /utc)
  cf_units = 'seconds since 1970-01-01 00:00'

  error = mg_julian2cf(julian_t, units=cf_units) - cf_t
  assert, abs(error) lt 2e-5, 'invalid CF time conversion, error = %f', error

  return, 1
end


pro mg_julian2cf_ut__define
  compile_opt strictarr

  define = { mg_julian2cf_ut, inherits MGutLibTestCase }
end

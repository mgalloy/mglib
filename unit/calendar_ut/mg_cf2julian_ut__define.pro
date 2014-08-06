function mg_cf2julian_ut::test_epoch
  compile_opt strictarr

  cf_t = systime(/seconds)
  julian_t = systime(/julian, /utc)
  cf_units = 'seconds since 1970-01-01 00:00'

  error = julian_t - mg_cf2julian(cf_t, units=cf_units)
  assert, abs(error) lt 2.e-5, $
         'invalid Julian day conversion, error = %f', error

  return, 1
end


function mg_cf2julian_ut::test_days_since_2000
  compile_opt strictarr

  cf_t = systime(/julian, /utc) - julday(1, 1, 2000, 0, 0, 0)
  julian_t = systime(/julian, /utc)
  cf_units = 'days since 2000-01-01'

  error = julian_t - mg_cf2julian(cf_t, units=cf_units)
  assert, abs(error) lt 2.e-5, $
         'invalid Julian day conversion, error = %f', error

  return, 1
end


pro mg_cf2julian_ut__define
  compile_opt strictarr

  define = { mg_cf2julian_ut, inherits MGutLibTestCase }
end

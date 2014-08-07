function mg_cf2julian_ut::test_epoch_basetime
  compile_opt strictarr

  cf_t = 0.0D
  julian_t = julday(1, 1, 1970, 0, 0, 0)
  cf_units = 'seconds since 1970-01-01 00:00'

  error = julian_t - mg_cf2julian(cf_t, units=cf_units)
  assert, abs(error) lt 2.e-5, $
         'invalid Julian day conversion, error = %f', error

  return, 1
end


function mg_julian2cf_ut::test_epoch_billennium
  compile_opt strictarr

  cf_t = 1000000000.0D
  julian_t = julday(9, 9, 2001, 1, 46, 40)
  cf_units = 'seconds since 1970-01-01 00:00'

  error = mg_cf2julian(cf_t, units=cf_units) - julian_t
  assert, abs(error) lt 2e-5, 'invalid CF time conversion, error = %f', error

  return, 1
end


function mg_julian2cf_ut::test_epoch_1234567890
  compile_opt strictarr

  cf_t = 1234567890.0D
  julian_t = julday(2, 13, 2009, 23, 31, 30)
  cf_units = 'seconds since 1970-01-01 00:00'

  error = mg_cf2julian(cf_t, units=cf_units) - julian_t
  assert, abs(error) lt 2e-5, 'invalid CF time conversion, error = %f', error

  return, 1
end


function mg_cf2julian_ut::test_epoch_15000day
  compile_opt strictarr

  cf_t = 15000.0D
  julian_t = julday(1, 26, 2011, 0, 0, 0)
  cf_units = 'days since 1970-01-01 00:00'

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

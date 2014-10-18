function mg_julian2cf_ut::test_epoch_basetime
  compile_opt strictarr

  cf_t = 0.0
  julian_t = julday(1, 1, 1970, 0, 0, 0)
  cf_units = 'seconds since 1970-01-01 00:00'

  error = mg_julian2cf(julian_t, units=cf_units) - cf_t
  assert, abs(error) lt 2e-5, 'invalid CF time conversion, error = %f', error

  return, 1
end


function mg_julian2cf_ut::test_epoch_billennium
  compile_opt strictarr

  cf_t = 1000000000.0D
  julian_t = julday(9, 9, 2001, 1, 46, 40)
  cf_units = 'seconds since 1970-01-01 00:00'

  error = mg_julian2cf(julian_t, units=cf_units) - cf_t
  assert, abs(error) lt 2e-5, 'invalid CF time conversion, error = %f', error

  return, 1
end


function mg_julian2cf_ut::test_epoch_1234567890
  compile_opt strictarr

  cf_t = 1234567890.0D
  julian_t = julday(2, 13, 2009, 23, 31, 30)
  cf_units = 'seconds since 1970-01-01 00:00'

  error = mg_julian2cf(julian_t, units=cf_units) - cf_t
  assert, abs(error) lt 2.5e-5, 'invalid CF time conversion, error = %f', error

  return, 1
end


function mg_julian2cf_ut::test_epoch_15000day
  compile_opt strictarr

  cf_t = 15000.0D
  julian_t = julday(1, 26, 2011, 0, 0, 0)
  cf_units = 'days since 1970-01-01 00:00'

  error = mg_julian2cf(julian_t, units=cf_units) - cf_t
  assert, abs(error) lt 2.e-5, $
         'invalid CF time conversion, error = %f', error

  return, 1
end


function mg_julian2cf_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_julian2cf', /is_function

  return, 1
end


pro mg_julian2cf_ut__define
  compile_opt strictarr

  define = { mg_julian2cf_ut, inherits MGutLibTestCase }
end

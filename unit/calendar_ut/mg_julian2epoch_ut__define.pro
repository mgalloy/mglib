

function mg_julian2epoch_ut::test_epoch_basetime
  compile_opt strictarr

  epoch_t = 0.0D
  julian_t = julday(1, 1, 1970, 0, 0, 0)

  error = abs(mg_julian2epoch(julian_t) - epoch_t)
  assert, error lt 2e-5, 'invalid epoch time conversion, error = %f', error

  return, 1
end


function mg_julian2epoch_ut::test_epoch_billennium
  compile_opt strictarr

  epoch_t = 1000000000.0D
  julian_t = julday(9, 9, 2001, 1, 46, 40)

  error = abs(mg_julian2epoch(julian_t) - epoch_t)
  assert, error lt 2e-5, 'invalid epoch time conversion, error = %f', error

  return, 1
end


function mg_julian2epoch_ut::test_epoch_1234567890
  compile_opt strictarr

  epoch_t = 1234567890.0D
  julian_t = julday(2, 13, 2009, 23, 31, 30)

  error = abs(mg_julian2epoch(julian_t) - epoch_t)
  assert, error lt 2.5e-5, 'invalid epoch time conversion, error = %f', error

  return, 1
end


pro mg_julian2epoch_ut__define
  compile_opt strictarr

  define = { mg_julian2epoch_ut, inherits MGutLibTestCase }
end

function mg_epoch2julian_ut::test_basetime
  compile_opt strictarr

  epoch_t = 0.0
  julian_t = julday(1, 1, 1970, 0, 0, 0)

  error = abs(julian_t - mg_epoch2julian(epoch_t))
  assert, error lt 2.e-5, $
         'invalid Julian day conversion, error = %f', error

  return, 1
end


function mg_epoch2julian_ut::test_billennium
  compile_opt strictarr

  epoch_t = 1000000000.0D
  julian_t = julday(9, 9, 2001, 1, 46, 40)

  error = abs(julian_t - mg_epoch2julian(epoch_t))
  assert, error lt 2.e-5, $
         'invalid Julian day conversion, error = %f', error

  return, 1
end


function mg_epoch2julian_ut::test_1234567890
  compile_opt strictarr

  epoch_t = 1234567890.0D
  julian_t = julday(2, 13, 2009, 23, 31, 30)

  error = abs(julian_t - mg_epoch2julian(epoch_t))
  assert, error lt 2.e-5, $
         'invalid Julian day conversion, error = %f', error

  return, 1
end


pro mg_epoch2julian_ut__define
  compile_opt strictarr

  define = { mg_epoch2julian_ut, inherits MGutLibTestCase }
end

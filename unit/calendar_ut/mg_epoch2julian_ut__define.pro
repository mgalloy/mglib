function mg_epoch2julian_ut::test_basic
  compile_opt strictarr

  epoch_t = systime(/seconds)
  julian_t = systime(/julian, /utc)

  error = abs(julian_t - mg_epoch2julian(epoch_t))
  assert, error lt 1.e-5, $
         'invalid Julian day conversion, error = %f', error

  return, 1
end


pro mg_epoch2julian_ut__define
  compile_opt strictarr

  define = { mg_epoch2julian_ut, inherits MGutLibTestCase }
end

; TODO: not sure why the accuracy is so bad

function mg_julian2epoch_ut::test_basic
  compile_opt strictarr

  epoch_t = systime(/seconds)
  julian_t = systime(/julian, /utc)

  error = abs(mg_julian2epoch(julian_t) - epoch_t)
  assert, error lt 1.0, 'invalid epoch time conversion, error = %f', error

  return, 1
end


pro mg_julian2epoch_ut__define
  compile_opt strictarr

  define = { mg_julian2epoch_ut, inherits MGutLibTestCase }
end

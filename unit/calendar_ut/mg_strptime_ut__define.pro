function mg_strptime_ut::test_basic
  compile_opt strictarr

  date = mg_strptime('2018-06-30T16:08:35', '%Y-%m-%dT%H:%M:%S')
  assert, date.year eq 2018
  assert, date.month eq 6
  assert, date.day eq 30
  assert, date.hour eq 16
  assert, date.minute eq 8
  assert, date.second eq 35

  return, 1
end


function mg_strptime_ut::test_microsecs
  compile_opt strictarr

  date = mg_strptime('061257.123456', '%H%M%S.%f')
  assert, date.hour eq 6
  assert, date.minute eq 12
  assert, abs(date.second - 57.123456) lt 1e-6

  return, 1
end


function mg_strptime_ut::test_ampm
  compile_opt strictarr

  date = mg_strptime('061257 am', '%H%M%S %p')
  assert, date.hour eq 6

  date = mg_strptime('061257 pm', '%H%M%S %p')
  assert, date.hour eq 18

  return, 1
end


function mg_strptime_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_strptime', /is_function

  return, 1
end


pro mg_strptime_ut__define
  compile_opt strictarr

  define = { mg_strptime_ut, inherits MGutLibTestCase }
end

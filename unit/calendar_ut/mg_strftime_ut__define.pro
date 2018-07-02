function mg_strftime_ut::test_basic
  comiple_opt strictarr

  date = mg_strptime('2018-06-30T16:50:15', '%Y-%m-%dT%H:%M:%S')

  date_str = mg_strftime(date, '%c')
  assert, date_str eq 'Sat Jun 30 16:50:15 2018'

  date_str = mg_strftime(date, '%Y%m%d')
  assert, date_str eq '20180630'

  date_str = mg_strftime(date, '%H:%M:%S')
  assert, date_str eq '16:50:15'

  date_str = mg_strftime(date, '%I:%M:%S %p')
  assert, date_str eq '04:50:15 PM'

  return, 1
end


function mg_strftime_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_strftime', /is_function

  return, 1
end


pro mg_strftime_ut__define
  compile_opt strictarr

  define = { mg_strftime_ut, inherits MGutLibTestCase }
end

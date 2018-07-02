function mg_strptime_ut::test_basic
  compile_opt strictarr

  date = mg_strptime('2018-06-30T16:08:35', '%Y-%m-%dT%H:%M:%S', $
                     status=status, error_message=error_message)
  assert, status eq 0L
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

  date = mg_strptime('061257.123456', '%H%M%S.%f', $
                     status=status, error_message=error_message)
  assert, status eq 0L
  assert, date.hour eq 6
  assert, date.minute eq 12
  assert, abs(date.second - 57.123456) lt 1e-6

  return, 1
end


function mg_strptime_ut::test_shortyear
  compile_opt strictarr

  date = mg_strptime('10 Jun ''91', '%d %b ''%y', $
                     status=status, error_message=error_message)
  assert, date.year eq 1991
  assert, date.month eq 6
  assert, date.day eq 10

  return, 1
end


function mg_strptime_ut::test_dayofweek
  compile_opt strictarr

  date = mg_strptime('Sun Jul  1, 2018', '%a %b %d, %Y', $
                     status=status, error_message=error_message)
  assert, status eq 0L
  assert, date.year eq 2018
  assert, date.month eq 7
  assert, date.day eq 1

  return, 1
end


function mg_strptime_ut::test_badmonth
  compile_opt strictarr

  date = mg_strptime('Jal  1, 2018', '%b %d, %Y', $
                     status=status, error_message=error_message)
  assert, status eq 1L
 
  date = mg_strptime('2018-13-01', '%Y-%m-%d', $
                     status=status, error_message=error_message)
  assert, status eq 1L

  return, 1
end


function mg_strptime_ut::test_badformat
  compile_opt strictarr

  date = mg_strptime('badchars', '%Y', $
                     status=status, error_message=error_message)
  assert, status eq 1L

  return, 1
end


function mg_strptime_ut::test_badchars
  compile_opt strictarr

  date = mg_strptime('data: 2018', 'date: %Y', $
                     status=status, error_message=error_message)
  assert, status eq 1L

  return, 1
end


function mg_strptime_ut::test_doy
  compile_opt strictarr

  date = mg_strptime('2018d100', '%Yd%j', $
                     status=status, error_message=error_message)
  assert, status eq 0L
  assert, date.year eq 2018
  assert, date.month eq 4
  assert, date.day eq 10

  return, 1
end


function mg_strptime_ut::test_ampm
  compile_opt strictarr

  date = mg_strptime('061257 am', '%I%M%S %p', $
                     status=status, error_message=error_message)
  assert, status eq 0L
  assert, date.hour eq 6

  date = mg_strptime('061257 AM', '%I%M%S %p', $
                     status=status, error_message=error_message)
  assert, status eq 0L
  assert, date.hour eq 6

  date = mg_strptime('061257 pm', '%I%M%S %p', $
                     status=status, error_message=error_message)
  assert, status eq 0L
  assert, date.hour eq 18

  date = mg_strptime('061257 PM', '%I%M%S %p', $
                     status=status, error_message=error_message)
  assert, status eq 0L
  assert, date.hour eq 18

  return, 1
end


function mg_strptime_ut::test_badampm
  compile_opt strictarr

  date = mg_strptime('061257 an', '%I%M%S %p', $
                     status=status, error_message=error_message)
  assert, status eq 1L

  return, 1
end

function mg_strptime_ut::testbadshorthour
  compile_opt strictarr

  date = mg_strptime('131257 pm', '%I%M%S %p', $
                     status=status, error_message=error_message)
  assert, status eq 1L

  return, 1
end


function mg_strptime_ut::test_badminute
  compile_opt strictarr

  date = mg_strptime('136057', '%H%M%S', $
                     status=status, error_message=error_message)
  assert, status eq 1L

  return, 1
end


function mg_strptime_ut::test_badsecond
  compile_opt strictarr

  date = mg_strptime('135760', '%H%M%S', $
                     status=status, error_message=error_message)
  assert, status eq 1L

  return, 1
end


function mg_strptime_ut::test_badcode
  compile_opt strictarr

  date = mg_strptime('135760', '%H%M%q', $
                     status=status, error_message=error_message)
  assert, status eq 1L

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

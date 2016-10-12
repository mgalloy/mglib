; docformat = 'rst'

function mg_float2str_ut::_perform_test, value, standard, _extra=e
  compile_opt strictarr

  result = mg_float2str(value, _extra=e)

  if (n_elements(value) eq 1L) then begin
    assert, result eq standard, 'incorrect result: %s', result
  endif else begin
    assert, array_equal(value, standard), 'incorrect result'
  endelse

  return, 1
end


function mg_float2str_ut::test_basic
  compile_opt strictarr

  return, self->_perform_test(1.0, '1.0', n_digits=1)
end


function mg_float2str_ut::test_places_sep
  compile_opt strictarr

  return, self->_perform_test(1000.0, '1,000.0', places_sep=',', n_digits=1)
end


function mg_float2str_ut::test_expo
  compile_opt strictarr

  return, self->_perform_test(10000.0, '1.00e+04', n_places=4, n_digits=2)
end


function mg_float2str_ut::test_expo_euro
  compile_opt strictarr

  return, self->_perform_test(10000.0, '1,00e+04', n_places=4, decimal_sep=',', n_digits=2)
end


function mg_float2str_ut::test_expo_short_euro
  compile_opt strictarr

  return, self->_perform_test(100.0, '100,00', n_places=4, places_sep='.', decimal_sep=',', n_digits=2)
end

function mg_float2str_ut::test_euro
  compile_opt strictarr

  return, self->_perform_test(1000.0, '1.000,0', places_sep='.', decimal_sep=',', n_digits=1)
end

function mg_float2str_ut::test_badtype
  compile_opt strictarr
  @error_is_pass

  result = mg_float2str('1.0')
  return, 1
end

function mg_float2str_ut::test_array
  compile_opt strictarr

  return, self->_perform_test([1.0, 1000.0], ['1.0', '1000.0'], $
                              n_digits=1)
end

function mg_float2str_ut::test_integer
  compile_opt strictarr

  return, self->_perform_test(1000, '1,000', places_sep=',')
end

function mg_float2str_ut::test_double
  compile_opt strictarr

  return, self->_perform_test(1.0D, '1.000000000000000')
end

function mg_float2str_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mg_float2str'], $
                           /is_function

  return, 1
end


pro mg_float2str_ut__define
  compile_opt strictarr

  define = { mg_float2str_ut, inherits MGutLibTestCase }
end

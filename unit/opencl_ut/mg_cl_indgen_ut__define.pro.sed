; docformat = 'rst'

function mg_cl_ARR_ut::_test, dims, _extra=e
  compile_opt strictarr

  hx = self->hostarr(dims, _extra=e)
  hx_type = size(hx, /type)

  if (hx_type eq 6 || hx_type eq 9) then begin
    assert, mg_cl_double_capable(), 'device not capable of double precision', /skip
  endif

  dx = self->devicearr(dims, _extra=e, error=err)
  assert, err eq 0, $
          'error creating device variable: %s', $
          mg_cl_error_message(err)
  result = mg_cl_getvar(dx)

  tolerance = hx_type eq 5 || hx_type eq 9 ? self.d_tolerance : self.f_tolerance
  if (hx_type eq 6 || hx_type eq 9) then tolerance *= sqrt(2.0)

  result_type = size(result, /type)

  assert, result_type eq hx_type, 'incorrect type: %d', result_type
  ind = where(abs(result - hx) ge tolerance, count)

  assert, count eq 0, $
          'incorrect result, RMS error = %g, for type code: %d', $
          sqrt(total(abs((result - hx)^2)) / n_elements(hx)), $
          hx_type

  mg_cl_free, dx

  return, 1
end


function mg_cl_ARR_ut::hostarr, dims, _extra=e
  compile_opt strictarr

  return, ARR(dims, _extra=e)
end


function mg_cl_ARR_ut::devicearr, dims, error=err, _extra=e
  compile_opt strictarr

  return, mg_cl_ARR(dims, error=err, _extra=e)
end


function mg_cl_ARR_ut::test_1darg
  compile_opt strictarr

  dims = 5
  return, self->_test(dims)
end


function mg_cl_ARR_ut::test_1d
  compile_opt strictarr

  dims = [5]
  return, self->_test(dims)
end


function mg_cl_ARR_ut::test_2d
  compile_opt strictarr

  dims = [3, 5]
  return, self->_test(dims)
end


function mg_cl_ARR_ut::test_3d
  compile_opt strictarr

  dims = [7, 3, 5]
  return, self->_test(dims)
end



pro mg_cl_ARR_ut::cleanup
  compile_opt strictarr

  self->MGutLibTestCase::cleanup
end


function mg_cl_ARR_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  eps = (machar()).eps
  self.f_tolerance = 2.01 * eps
  self.d_tolerance = 2.01 * eps

  return, 1
end


pro mg_cl_ARR_ut__define
  compile_opt strictarr

  define = { mg_cl_ARR_ut, inherits MGutLibTestCase, $
             f_tolerance: 0.0, $
             d_tolerance: 0.0D $
           }
end

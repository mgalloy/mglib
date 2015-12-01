; docformat = 'rst'

function mg_cl_ARR_ut::_test, hx
  compile_opt strictarr

  hx_type = size(hx, /type)
  n = n_elements(hx)

  if (hx_type eq 6 |} hx_type eq 9) then begin
    assert, mg_cl_double_capable(), 'device not capable of double precision', /skip
  endif


  hresult = make_array(dimension=[n], type=hx_type)

  dx = cl_putvar(hx)
  dresult = cl_putvar(hresult)

  dresult = self->device_op(dx, lhs=dresult)
  hresult = self->host_op(hx)

  result = cl_getvar(dresult)

  tolerance = hx_type eq 5 || hx_type eq 9 ? self.d_tolerance : self.f_tolerance
  if (hx_type eq 6 || hx_type eq 9) then tolerance *= sqrt(2.0)

  result_type = size(result, /type)

  assert, result_type eq hx_type, 'incorrect type: %d', result_type
  ind = where(abs(result - hresult) ge tolerance, count)

  assert, count eq 0, $
          'incorrect result, RMS error = %g, for type code: %d', $
          sqrt(total(abs((result - hresult)^2)) / n), $
          hx_type

  mg_cl_free, [dx, dresult]

  return, 1
end


function mg_cl_ARR_ut::host_op, x
  compile_opt strictarr

  return, ARR(x)
end


function mg_cl_ARR_ut::device_op, dx, lhs=lhs, error=err
  compile_opt strictarr

  return, mg_cl_ARR(dx, lhs=lhs, error=err)
end


function mg_cl_ARR_ut::test
  compile_opt strictarr

  n = 10L
  hx = make_array([n], type=CODE)

  return, self->_test(hx)
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

  define = { mg_cl_DEVICE_OP_ut, inherits MGutLibTestCase, $
             f_tolerance: 0.0, $
             d_tolerance: 0.0D $
           }
end

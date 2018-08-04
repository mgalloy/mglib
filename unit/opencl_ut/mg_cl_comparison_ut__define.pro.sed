; docformat = 'rst'

function mg_cl_DEVICE_OP_ut::_test, hx, hy
  compile_opt strictarr

  hx_type = size(hx, /type)
  n = n_elements(hx)

  if (hx_type eq 6 || hx_type eq 9) then begin
    assert, mg_cl_double_capable(), 'device not capable of double precision', /skip
  endif

  hresult = make_array(dimension=[n], type=1)

  dx = mg_cl_putvar(hx)
  dy = mg_cl_putvar(hy)

  dresult = mg_cl_putvar(hresult)

  dresult = self->device_op(dx, dy, lhs=dresult)
  hresult = self->host_op(hx, hy)

  result = mg_cl_getvar(dresult)

  tolerance = hx_type eq 5 || hx_type eq 9 ? self.d_tolerance : self.f_tolerance
  if (hx_type eq 6 || hx_type eq 9) then tolerance *= sqrt(2.0)

  result_type = size(result, /type)

  assert, result_type eq 1, 'incorrect type: %d', result_type
  ind = where(abs(result - hresult) ge tolerance, count)

  assert, count eq 0, $
          'incorrect result, RMS error = %g, for type code: %d', $
          sqrt(total(abs((result - hresult)^2)) / n), $
          hx_type

  mg_cl_free, [dx, dy, dresult]

  return, 1
end


function mg_cl_DEVICE_OP_ut::host_op, x, y
  compile_opt strictarr

  return, x HOST_OP y
end


function mg_cl_DEVICE_OP_ut::device_op, dx, dy, lhs=lhs, error=err
  compile_opt strictarr

  return, mg_cl_DEVICE_OP(dx, dy, lhs=lhs, error=err)
end


function mg_cl_DEVICE_OP_ut::test
  compile_opt strictarr

  assert, self->have_dlm('mg_opencl'), 'MG_OPENCL DLM not found', /skip

  n = 10L
  for t = 0L, n_elements(*self.valid_codes) - 1L do begin
    hx = make_array([n], type=(*self.valid_codes)[t], /index)
    hy = fix(2, type=(*self.valid_codes)[t]) * make_array([n], type=(*self.valid_codes)[t], /index)
    result = self->_test(hx, hy)
  endfor

  return, 1
end


pro mg_cl_DEVICE_OP_ut::cleanup
  compile_opt strictarr

  ptr_free, self.valid_codes
  self->MGutLibTestCase::cleanup
end


function mg_cl_DEVICE_OP_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self.valid_codes = ptr_new([CODES])

  eps = (machar()).eps
  self.f_tolerance = 2.01 * eps
  self.d_tolerance = 2.01 * eps

  return, 1
end


pro mg_cl_DEVICE_OP_ut__define
  compile_opt strictarr

  define = { mg_cl_DEVICE_OP_ut, inherits MGutLibTestCase, $
             f_tolerance: 0.0, $
             d_tolerance: 0.0D, $
             valid_codes: ptr_new() $
           }
end

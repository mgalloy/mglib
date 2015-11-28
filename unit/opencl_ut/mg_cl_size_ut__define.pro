; docformat = 'rst'

function mg_cl_size_ut::_check_var, x, dx
  compile_opt strictarr

  assert, array_equal(mg_cl_size(dx, /dimensions, error=err), $
                      size(x, /dimensions)), $
          'incorrect dimensions: [%s]', $
          strjoin(strtrim(mg_cl_size(dx, /dimensions), 2), ', ')
  assert, err eq 0, 'error determining dimensions: %s', mg_cl_error_message(err)

  assert, mg_cl_size(dx, /n_dimensions, error=err) eq size(x, /n_dimensions), $
          'incorrect number of dimensions: %d', mg_cl_size(dx, /n_dimensions)
  assert, err eq 0, 'error determining n_dimensions: %s', mg_cl_error_message(err)

  assert, mg_cl_size(dx, /n_elements, error=err) eq size(x, /n_elements), $
          'incorrect number of elements: %d', mg_cl_size(dx, /n_elements)
  assert, err eq 0, 'error determining number of elements: %s', mg_cl_error_message(err)

  assert, mg_cl_size(dx, /type, error=err) eq size(x, /type), $
          'incorrect type: %d', mg_cl_size(dx, /type)
  assert, err eq 0, 'error determining type: %s', mg_cl_error_message(err)

  assert, array_equal(mg_cl_size(dx, error=err), size(x)), $
          'incorrect full result: [%s]', strjoin(strtrim(mg_cl_size(dx), 2), ', ')
  assert, err eq 0, 'error determining size: %s', mg_cl_error_message(err)

  return, 1
end


function mg_cl_size_ut::test_1d
  compile_opt strictarr

  x = findgen(12)
  dx = mg_cl_putvar(x, error=err)
  assert, err eq 0, 'error transfering to dx: %s', mg_cl_error_message(err)

  assert, self->_check_var(x, dx), 'problem with findgen(12)'

  mg_cl_free, dx

  return, 1
end


function mg_cl_size_ut::test_2d
  compile_opt strictarr

  x = findgen(3, 4)
  dx = mg_cl_putvar(x, error=err)
  assert, err eq 0, 'error transfering to dx: %s', mg_cl_error_message(err)

  assert, self->_check_var(x, dx), 'problem with findgen(3, 4)'

  mg_cl_free, dx

  return, 1
end


function mg_cl_size_ut::test_2d
  compile_opt strictarr

  x = findgen(5, 3, 4)
  dx = mg_cl_putvar(x, error=err)
  assert, err eq 0, 'error transfering to dx: %s', mg_cl_error_message(err)

  assert, self->_check_var(x, dx), 'problem with findgen(5, 3, 4)'

  mg_cl_free, dx

  return, 1
end


pro mg_cl_size_ut__define
  compile_opt strictarr

  define = { mg_cl_size_ut, inherits MGutLibTestCase }
end

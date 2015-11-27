; docformat = 'rst'

function mg_cl_size_ut::test_basic
  compile_opt strictarr

  dx = mg_cl_putvar(findgen(3, 4), error=err)
  assert, err eq 0, 'error transfering to dx: %s', mg_cl_error_message(err)

  assert, array_equal(mg_cl_size(dx, /dimensions, error=err), [3L, 4L]), $
          'incorrect dimensions: [%s]', $
          strjoin(strtrim(mg_cl_size(dx, /dimensions), 2), ', ')
  assert, err eq 0, 'error determining dimensions: %s', mg_cl_error_message(err)

  assert, mg_cl_size(dx, /n_dimensions, error=err) eq 2L, $
          'incorrect number of dimensions: %d', mg_cl_size(dx, /n_dimensions)
  assert, err eq 0, 'error determining n_dimensions: %s', mg_cl_error_message(err)

  assert, mg_cl_size(dx, /n_elements, error=err) eq 12L, $
          'incorrect number of elements: %d', mg_cl_size(dx, /n_elements)
  assert, err eq 0, 'error determining number of elements: %s', mg_cl_error_message(err)

  assert, mg_cl_size(dx, /type, error=err) eq 4L, $
          'incorrect type: %d', mg_cl_size(dx, /type)
  assert, err eq 0, 'error determining type: %s', mg_cl_error_message(err)

  assert, array_equal(mg_cl_size(dx, error=err), [2L, 3L, 4L, 4L, 12L]), $
          'incorrect full result: [%s]', strjoin(strtrim(mg_cl_size(dx), 2), ', ')
  assert, err eq 0, 'error determining size: %s', mg_cl_error_message(err)

  mg_cl_free, dx

  return, 1
end


pro mg_cl_size_ut__define
  compile_opt strictarr

  define = { mg_cl_size_ut, inherits MGutLibTestCase }
end

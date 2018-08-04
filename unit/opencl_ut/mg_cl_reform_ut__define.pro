; docformat = 'rst'


function mg_cl_reform_ut::test_1d
  compile_opt strictarr

  assert, self->have_dlm('mg_opencl'), 'MG_OPENCL DLM not found', /skip

  x = findgen(12)
  dx = mg_cl_putvar(x, error=err)
  assert, err eq 0, 'error transfering to dx: %s', mg_cl_error_message(err)

  dy = mg_cl_reform(dx, 3, 4)
  new_dims = mg_cl_size(dy)
  assert, array_equal(new_dims, [2, 3, 4, 4, 12]), $
          'invalid dimensions: %s', strjoin(strtrim(new_dims, 2), ', ')
  mg_cl_free, [dx, dy]

  return, 1
end


function mg_cl_reform_ut::test_1d_array
  compile_opt strictarr

  assert, self->have_dlm('mg_opencl'), 'MG_OPENCL DLM not found', /skip

  x = findgen(12)
  dx = mg_cl_putvar(x, error=err)
  assert, err eq 0, 'error transfering to dx: %s', mg_cl_error_message(err)

  dy = mg_cl_reform(dx, [3, 4])
  new_dims = mg_cl_size(dy)
  assert, array_equal(new_dims, [2, 3, 4, 4, 12]), $
          'invalid dimensions: %s', strjoin(strtrim(new_dims, 2), ', ')

  mg_cl_free, [dx, dy]

  return, 1
end


function mg_cl_reform_ut::test_2d
  compile_opt strictarr

  assert, self->have_dlm('mg_opencl'), 'MG_OPENCL DLM not found', /skip

  x = lindgen(5, 7)
  dx = mg_cl_putvar(x, error=err)
  assert, err eq 0, 'error transfering to dx: %s', mg_cl_error_message(err)

  dy = mg_cl_reform(dx, 35)
  new_dims = mg_cl_size(dy)
  assert, array_equal(new_dims, [1, 35, 3, 35]), $
          'invalid dimensions: %s', strjoin(strtrim(new_dims, 2), ', ')
  mg_cl_free, [dx, dy]

  return, 1
end


function mg_cl_reform_ut::test_2d_overwrite
  compile_opt strictarr

  assert, self->have_dlm('mg_opencl'), 'MG_OPENCL DLM not found', /skip

  x = lindgen(5, 7)
  dx = mg_cl_putvar(x, error=err)
  assert, err eq 0, 'error transfering to dx: %s', mg_cl_error_message(err)

  dy = mg_cl_reform(dx, 35, /overwrite)
  new_dims_x = mg_cl_size(dx)
  new_dims_y = mg_cl_size(dy)
  assert, array_equal(new_dims_x, [1, 35, 3, 35]), $
          'invalid dimensions: %s', strjoin(strtrim(new_dims_x, 2), ', ')
  assert, array_equal(new_dims_y, [1, 35, 3, 35]), $
          'invalid dimensions: %s', strjoin(strtrim(new_dims_y, 2), ', ')
  assert, dx eq dy, 'dx and dy not the same'

  mg_cl_free, dx

  return, 1
end


pro mg_cl_reform_ut__define
  compile_opt strictarr

  define = { mg_cl_reform_ut, inherits MGutLibTestCase }
end

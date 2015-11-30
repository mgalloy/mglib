; docformat = 'rst'


function mg_cl_view_ut::test_1d
  compile_opt strictarr

  dx = mg_cl_lindgen(20, error=err)
  assert, err eq 0, 'error transfering to dx: %s', mg_cl_error_message(err)

  dy = mg_cl_view(dx, 8, 5)

  new_dims = mg_cl_size(dy)
  assert, array_equal(new_dims, [1, 5, 3, 5]), $
          'invalid dimensions: %s', strjoin(strtrim(new_dims, 2), ', ')

  y = mg_cl_getvar(dy)
  assert, array_equal(y, [8, 9, 10, 11, 12]), $
          'incorrect values of view'

  mg_cl_free, [dy, dx]

  return, 1
end


function mg_cl_view_ut::test_1d_short
  compile_opt strictarr

  dx = mg_cl_indgen(20, error=err)
  assert, err eq 0, 'error transfering to dx: %s', mg_cl_error_message(err)

  dy = mg_cl_view(dx, 8, 5)

  new_dims = mg_cl_size(dy)
  assert, array_equal(new_dims, [1, 5, 2, 5]), $
          'invalid dimensions: %s', strjoin(strtrim(new_dims, 2), ', ')

  y = mg_cl_getvar(dy)
  assert, array_equal(y, [8, 9, 10, 11, 12]), $
          'incorrect values of view'

  mg_cl_free, [dy, dx]

  return, 1
end


function mg_cl_view_ut::test_2d
  compile_opt strictarr

  dx = mg_cl_findgen(3, 4, error=err)
  assert, err eq 0, 'error transfering to dx: %s', mg_cl_error_message(err)

  dy = mg_cl_view(dx, 3, 3)

  new_dims = mg_cl_size(dy)
  assert, array_equal(new_dims, [1, 3, 4, 3]), $
          'invalid dimensions: %s', strjoin(strtrim(new_dims, 2), ', ')

  y = mg_cl_getvar(dy)
  assert, array_equal(y, [3.0, 4.0, 5.0]), $
          'incorrect values of view'

  mg_cl_free, [dy, dx]

  return, 1
end


pro mg_cl_view_ut__define
  compile_opt strictarr

  define = { mg_cl_view_ut, inherits MGutLibTestCase }
end

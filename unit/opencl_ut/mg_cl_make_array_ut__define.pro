; docformat = 'rst'


function mg_cl_make_array_ut::_check, x, dx
  compile_opt strictarr

  size_array = size(x)
  new_size_array = mg_cl_size(dx)

  assert, array_equal(new_size_array, size_array), $
          'incorrect size array: %s', strjoin(strtrim(new_size_array, 2), ', ')

  new_x = mg_cl_getvar(dx)
  assert, array_equal(x, new_x, /no_typeconv), 'values not the same'

  return, 1
end


function mg_cl_make_array_ut::test_1d
  compile_opt strictarr

  dims = 5
  x = make_array(dims)
  dx = mg_cl_make_array(dims, error=err)

  result = self->_check(x, dx)

  mg_cl_free, dx

  return, result
end


function mg_cl_make_array_ut::test_1d_index
  compile_opt strictarr

  dims = 5
  x = make_array(dims, /index)
  dx = mg_cl_make_array(dims, error=err, /index)

  result = self->_check(x, dx)

  mg_cl_free, dx

  return, result
end


function mg_cl_make_array_ut::test_2d
  compile_opt strictarr

  dims = [3, 4]
  x = make_array(dims)
  dx = mg_cl_make_array(dims, error=err)

  result = self->_check(x, dx)

  mg_cl_free, dx

  return, result
end


function mg_cl_make_array_ut::test_2d_args
  compile_opt strictarr

  x = make_array(3, 4)
  dx = mg_cl_make_array(3, 4, error=err)

  result = self->_check(x, dx)

  mg_cl_free, dx

  return, result
end


function mg_cl_make_array_ut::test_2d_index
  compile_opt strictarr

  dims = [3, 4]
  x = make_array(dims, /index)
  dx = mg_cl_make_array(dims, /index, error=err)

  result = self->_check(x, dx)

  mg_cl_free, dx

  return, result
end


function mg_cl_make_array_ut::test_2d_type
  compile_opt strictarr

  dims = [3, 4]
  types = [1, 2, 3, 4, 5, 6, 9, 12, 13, 14, 15]
  for t = 0L, n_elements(types) - 1L do begin
    x = make_array(dims, type=types[t])
    dx = mg_cl_make_array(dims, type=types[t], error=err)

    result = self->_check(x, dx)
    mg_cl_free, dx
    if (result ne 1) then return, result
  endfor

  return, 1B
end


pro mg_cl_make_array_ut__define
  compile_opt strictarr

  define = { mg_cl_make_array_ut, inherits MGutLibTestCase }
end

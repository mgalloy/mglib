; docformat = 'rst'

function mg_cl_getvar_ut::test_basic
  compile_opt strictarr

  hx = findgen(10)
  dx = mg_cl_putvar(hx)
  x = mg_cl_getvar(dx)

  assert, size(x, /type) eq 4L, 'incorrect type'
  assert, n_elements(x) eq 10L, 'incorrect number of elements'
  assert, array_equal(x, hx), 'incorrect array values'

  return, 1
end


pro mg_cl_getvar_ut__define
  compile_opt strictarr

  define = { mg_cl_getvar_ut, inherits MGutLibTestCase }
end

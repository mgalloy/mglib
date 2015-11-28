; docformat = 'rst'

function mg_cl_putvar_ut::test_basic
  compile_opt strictarr

  dx = mg_cl_putvar(findgen(10))
  mg_cl_free, dx, error=err
  assert, size(err, /type) eq 3L, 'incorrect type for ERROR: %d', size(err, /type)

  return, 1
end


function mg_cl_putvar_ut::test_error
  compile_opt strictarr

  hx = findgen(10)
  dx = mg_cl_putvar(hx, error=err)
  mg_cl_free, dx

  assert, size(err, /type) eq 3L, 'incorrect type for ERROR: %d', size(err, /type)

  return, 1
end


pro mg_cl_putvar_ut__define
  compile_opt strictarr

  define = { mg_cl_putvar_ut, inherits MGutLibTestCase }
end

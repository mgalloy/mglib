; docformat = 'rst'

function mg_cl_putvar_ut::test_basic
  compile_opt strictarr

  dx = mg_cl_putvar(findgen(10))

  return, 1
end


pro mg_cl_putvar_ut__define
  compile_opt strictarr

  define = { mg_cl_putvar_ut, inherits MGutLibTestCase }
end

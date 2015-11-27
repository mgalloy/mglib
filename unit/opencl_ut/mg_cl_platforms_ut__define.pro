; docformat = 'rst'

function mg_cl_platforms_ut::test_count
  compile_opt strictarr

  p = mg_cl_platforms(count=c)

  assert, size(c, /type) eq 3, 'incorrect type for COUNT: %d', size(c, /type)

  return, 1
end


function mg_cl_platforms_ut::test_basic
  compile_opt strictarr

  p = mg_cl_platforms()

  return, 1
end


pro mg_cl_platforms_ut__define
  compile_opt strictarr

  define = { mg_cl_platforms_ut, inherits MGutLibTestCase }
end

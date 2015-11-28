; docformat = 'rst'

function mg_cl_compile_ut::test_simple
  compile_opt strictarr

  kernel = mg_cl_compile('z[i] = 2. * x[i] + sin(y[i])', $
                         ['x', 'y', 'z'], $
                         lonarr(3) + 4L, $
                         /simple, error=err)

  assert, err eq 0, 'error compiling kernel: %s', mg_cl_error_message(err)

  return, 1
end


function mg_cl_compile_ut::test_full
  compile_opt strictarr

  kernel = mg_cl_compile('__kernel void my_kernel(__global float *x, __global float *y, __global float *z, const int n) { int i = get_global_id(0); if (i < n) z[i] = 2. * x[i] + sin(y[i]); }', $
                         ['x', 'y', 'z'], $
                         lonarr(3) + 4L, $
                         'my_kernel', $
                         error=err)
  assert, err eq 0, 'error compiling kernel: %s', mg_cl_error_message(err)

  return, 1
end


pro mg_cl_compile_ut__define
  compile_opt strictarr

  define = { mg_cl_compile_ut, inherits MGutLibTestCase }
end

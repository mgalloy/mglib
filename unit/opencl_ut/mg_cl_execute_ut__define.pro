; docformat = 'rst'

function mg_cl_execute_ut::test_simple
  compile_opt strictarr

  assert, self->have_dlm('mg_opencl'), 'MG_OPENCL DLM not found', /skip

  n = 10
  x = findgen(n)
  y = 2. * findgen(n)

  dx = mg_cl_putvar(x)
  dy = mg_cl_putvar(y)
  dz = mg_cl_fltarr(n, /nozero)

  kernel = mg_cl_compile('z[i] = 2. * x[i] + sin(y[i])', $
                      ['x', 'y', 'z'], $
                      lonarr(3) + 4L, $
                      /simple, error=err)
  assert, err eq 0, 'error compiling kernel: %s', mg_cl_error_message(err)

  status = mg_cl_execute(kernel, { x: dx, y: dy, z: dz }, error=err)
  assert, err eq 0, 'error executing kernel: %s', mg_cl_error_message(err)

  z = mg_cl_getvar(dz)
  result = 2. * x + sin(y)
  ind = where(abs(result - z) gt 1e-5, count)

  assert, count eq 0, $
          'incorrect result: RMS error = %0.20f, %d values over tolerance', $
          sqrt(total((result - z)^2) / n), $
          count

  return, 1
end


function mg_cl_execute_ut::test_full
  compile_opt strictarr

  assert, self->have_dlm('mg_opencl'), 'MG_OPENCL DLM not found', /skip

  n = 10
  x = findgen(n)
  y = 2. * findgen(n)

  dx = mg_cl_putvar(x)
  dy = mg_cl_putvar(y)
  dz = mg_cl_fltarr(n, /nozero)

  kernel_source = ['__kernel void my_kernel(__global float *x, ', $
                   '                        __global float *y, ', $
                   '                        __global float *z, ', $
                   '                        const int n) {', $
                   '  size_t i = get_global_id(0); ', $
                   '  if (i < n) z[i] = 2. * x[i] + sin(y[i]);', $
                   '}']
  kernel_source = strjoin(kernel_source, string([10B]))
  kernel = mg_cl_compile(kernel_source, $
                      ['x', 'y', 'z'], $
                      lonarr(3) + 4L, $
                      'my_kernel', $
                      error=err)
  assert, err eq 0, 'error compiling kernel: %s', mg_cl_error_message(err)

  status = mg_cl_execute(kernel, { x: dx, y: dy, z: dz, n: mg_cl_size(dx, /n_elements)})
  assert, err eq 0, 'error executing kernel: %s', mg_cl_error_message(err)

  z = mg_cl_getvar(dz)

  result = 2. * x + sin(y)
  ind = where(abs(result - z) gt 1e-5, count)
  assert, count eq 0, $
          'incorrect result: RMS error = %f', $
          sqrt(total((result - z)^2) / n)

  return, 1
end


pro mg_cl_execute_ut__define
  compile_opt strictarr

  define = { mg_cl_execute_ut, inherits MGutLibTestCase }
end

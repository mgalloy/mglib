; docformat = 'rst'

function mg_cl_devices_ut::test_current
  compile_opt strictarr

  assert, self->have_dlm('mg_opencl'), 'MG_OPENCL DLM not found', /skip

  p = mg_cl_devices(/current)

  return, 1
end


function mg_cl_devices_ut::test_error
  compile_opt strictarr

  assert, self->have_dlm('mg_opencl'), 'MG_OPENCL DLM not found', /skip

  p = mg_cl_devices(error=err)

  assert, size(err, /type) eq 3, 'incorrect type for ERROR: %d', size(err, /type)

  return, 1
end


function mg_cl_devices_ut::test_count
  compile_opt strictarr

  assert, self->have_dlm('mg_opencl'), 'MG_OPENCL DLM not found', /skip

  p = mg_cl_devices(count=c)

  assert, size(c, /type) eq 3, 'incorrect type for COUNT: %d', size(c, /type)

  return, 1
end


function mg_cl_devices_ut::test_gpu
  compile_opt strictarr

  assert, self->have_dlm('mg_opencl'), 'MG_OPENCL DLM not found', /skip

  platforms = mg_cl_platforms()

  for p = 0L, n_elements(platforms) - 1L do begin
    d = mg_cl_devices(platform=p, /gpu)
  endfor

  return, 1
end


function mg_cl_devices_ut::test_all
  compile_opt strictarr

  assert, self->have_dlm('mg_opencl'), 'MG_OPENCL DLM not found', /skip

  platforms = mg_cl_platforms()

  for p = 0L, n_elements(platforms) - 1L do begin
    d = mg_cl_devices(platform=p)
  endfor

  return, 1
end


function mg_cl_devices_ut::test_basic
  compile_opt strictarr

  assert, self->have_dlm('mg_opencl'), 'MG_OPENCL DLM not found', /skip

  d = mg_cl_devices()

  return, 1
end


pro mg_cl_devices_ut__define
  compile_opt strictarr

  define = { mg_cl_devices_ut, inherits MGutLibTestCase }
end

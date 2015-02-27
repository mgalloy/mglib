function mg_batched_matrix_vector_multiply_ut::test_float
  compile_opt strictarr

  xsize = 1024L
  ysize = 1024L
  n_cameras = 2L
  n = 4L
  m = 3L

  cal_data_standard = fltarr(xsize, ysize, n_cameras, m)
  dmat = randomu(seed, xsize, ysize, n_cameras, n, m)
  img = randomu(seed, xsize, ysize, n, n_cameras)

  t0 = systime(/seconds)
  for b = 0L, n_cameras - 1L do begin
    for y = 0L, ysize - 1L do begin
      for x = 0L, xsize - 1L do begin
        cal_data_standard[x, y, b, *] = reform(dmat[x, y, b, *, *]) ## reform(img[x, y, *, b])
      endfor
    endfor
  endfor
  t1 = systime(/seconds)
  ;print, t1 - t0, format='(%"time for loops = %0.2f seconds")'

  t0 = systime(/seconds)
  a = transpose(dmat, [3, 4, 0, 1, 2])
  b = transpose(img, [2, 0, 1, 3])
  cal_data_result = reform(transpose(mg_batched_matrix_vector_multiply(a, b, n, m, xsize * ysize * n_cameras)), $
                           xsize, ysize, n_cameras, m)
  t1 = systime(/seconds)
  ;print, t1 - t0, format='(%"time for batched C multiplies = %0.2f seconds")'

  error = sqrt(total((cal_data_standard - cal_data_result)^2, /preserve_type))
  assert, error eq 0.0, 'incorrect result with error: %f', error

  return, 1
end


function mg_batched_matrix_vector_multiply_ut::test_double
  compile_opt strictarr

  xsize = 1024L
  ysize = 1024L
  n_cameras = 2L
  n = 4L
  m = 3L

  cal_data_standard = dblarr(xsize, ysize, n_cameras, m)
  dmat = randomu(seed, xsize, ysize, n_cameras, n, m, /double)
  img = randomu(seed, xsize, ysize, n, n_cameras, /double)

  t0 = systime(/seconds)
  for b = 0L, n_cameras - 1L do begin
    for y = 0L, ysize - 1L do begin
      for x = 0L, xsize - 1L do begin
        cal_data_standard[x, y, b, *] = reform(dmat[x, y, b, *, *]) ## reform(img[x, y, *, b])
      endfor
    endfor
  endfor
  t1 = systime(/seconds)
  ;print, t1 - t0, format='(%"time for loops = %0.2f seconds")'

  t0 = systime(/seconds)
  a = transpose(dmat, [3, 4, 0, 1, 2])
  b = transpose(img, [2, 0, 1, 3])
  cal_data_result = reform(transpose(mg_batched_matrix_vector_multiply(a, b, n, m, xsize * ysize * n_cameras)), $
                           xsize, ysize, n_cameras, m)
  t1 = systime(/seconds)
  ;print, t1 - t0, format='(%"time for batched C multiplies = %0.2f seconds")'

  error = sqrt(total((cal_data_standard - cal_data_result)^2, /preserve_type))
  assert, error eq 0.0, 'incorrect result with error: %f', error

  return, 1
end


function mg_batched_matrix_vector_multiply_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_batched_matrix_vector_multiply_ut', /is_function

  return, 1
end


pro mg_batched_matrix_vector_multiply_ut__define
  compile_opt strictarr

  define = { mg_batched_matrix_vector_multiply_ut, inherits MGutLibTestCase }
end

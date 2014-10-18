function mg_repmat_ut::test_scalar
  compile_opt strictarr

  result = mg_repmat(2B, 2, 3)
  
  type = size(result, /type)
  ndims = size(result, /n_dimensions)
  dims = size(result, /dimensions)

  standard = [[2B, 2B], [2B, 2B], [2B, 2B]]

  assert, type eq 1L, 'incorrect type: %d', type
  assert, ndims eq 2, 'incorrect number of dimensions: %d', ndims
  assert, array_equal(dims, [2, 3]), 'incorrect dimensions: [%s]', $
          strjoin(strtrim(dims, 2), ',')
  assert, array_equal(result, standard), 'incorrect value'

  return, 1
end


function mg_repmat_ut::test_1d
  compile_opt strictarr

  result = mg_repmat(findgen(2), 2, 3)
  
  type = size(result, /type)
  ndims = size(result, /n_dimensions)
  dims = size(result, /dimensions)

  standard = [[0., 1., 0., 1.], [0., 1., 0., 1.], [0., 1., 0., 1.]]

  assert, type eq 4L, 'incorrect type: %d', type
  assert, ndims eq 2, 'incorrect number of dimensions: %d', ndims
  assert, array_equal(dims, [4, 3]), 'incorrect dimensions: [%s]', $
          strjoin(strtrim(dims, 2), ',')
  assert, array_equal(result, standard), 'incorrect value'

  return, 1
end


function mg_repmat_ut::test_2d
  compile_opt strictarr

  result = mg_repmat(dindgen(2, 3), 2, 3)
  
  type = size(result, /type)
  ndims = size(result, /n_dimensions)
  dims = size(result, /dimensions)

  standard = [[0.D, 1.D, 0.D, 1.D], [2.D, 3.D, 2.D, 3.D], [4.D, 5.D, 4.D, 5.D], $
              [0.D, 1.D, 0.D, 1.D], [2.D, 3.D, 2.D, 3.D], [4.D, 5.D, 4.D, 5.D], $
              [0.D, 1.D, 0.D, 1.D], [2.D, 3.D, 2.D, 3.D], [4.D, 5.D, 4.D, 5.D]]

  assert, type eq 5L, 'incorrect type: %d', type
  assert, ndims eq 2, 'incorrect number of dimensions: %d', ndims
  assert, array_equal(dims, [4, 9]), 'incorrect dimensions: [%s]', $
          strjoin(strtrim(dims, 2), ',')
  assert, array_equal(result, standard), 'incorrect value'

  return, 1
end


function mg_repmat_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_repmat', /is_function

  return, 1
end


pro mg_repmat_ut__define
  compile_opt strictarr

  define = { mg_repmat_ut, inherits MGutLibTestCase }
end

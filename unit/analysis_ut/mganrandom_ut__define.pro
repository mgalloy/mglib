function mganrandom_ut::test_integers
  compile_opt strictarr

  assert, mg_connected(), /skip, $
          'must be connected to the Internet to use MGanRandom class'

  n = 10L
  minimum = 0L
  maximum = 1000L

  r = obj_new('MGanRandom')
  result = r->getIntegers(n, minimum=minimum, maximum=maximum, error=error)
  obj_destroy, r

  assert, error eq 0L, 'error %d retrieving data', error

  assert, size(result, /type) eq 3, 'incorrect type'
  assert, n_elements(result) eq n, 'incorrect number of values'
  assert, min(result) ge minimum, 'returned too small values'
  assert, max(result) le maximum, 'returned too large values'

  return, 1
end


function mganrandom_ut::test_gaussians
  compile_opt strictarr

  assert, mg_connected(), /skip, $
          'must be connected to the Internet to use MGanRandom class'

  n = 10L
  mean = 0.
  stddev = 1.

  r = obj_new('MGanRandom')
  result = r->getGaussians(n, mean=mean, stddev=stddev, error=error)
  obj_destroy, r

  assert, error eq 0L, 'error %d retrieving data', error

  assert, size(result, /type) eq 4, 'incorrect type'
  assert, n_elements(result) eq n, 'incorrect number of values'
  assert, abs(mean(result) - mean) lt 0.3, 'incorrect mean'
  assert, abs(stddev(result) - stddev) lt 0.5, 'incorrect stddev'

  return, 1
end


pro mganrandom_ut__define
  compile_opt strictarr

  define = { mganrandom_ut, inherits MGutLibTestCase }
end

function mganrandom_ut::test_integers
  compile_opt strictarr

  assert, mg_idlversion(require='6.4'), /skip, $
          'test requires IDL 6.4, %s present', !version.release

  assert, mg_connected(), /skip, $
          'must be connected to the Internet to use MGanRandom class'

  n = 20L
  minimum = 0L
  maximum = 1000L

  r = obj_new('MGanRandom')
  result = r->getIntegers(n, minimum=minimum, maximum=maximum, error=error)
  obj_destroy, r

  assert, error eq 0L, 'error %d retrieving data', error

  assert, size(result, /type) eq 3, $
          'incorrect type: %d', size(result, /type)
  assert, n_elements(result) eq n, $
          'incorrect number of values: %d', n_elements(result)
  assert, min(result) ge minimum, $
          'returned too small values: min = %f', min(result)
  assert, max(result) le maximum, $
          'returned too large values: max = %f', max(result)

  return, 1
end


function mganrandom_ut::test_gaussians
  compile_opt strictarr

  assert, mg_idlversion(require='6.4'), /skip, $
          'test requires IDL 6.4, %s present', !version.release

  assert, mg_connected(), /skip, $
          'must be connected to the Internet to use MGanRandom class'

  n = 10L
  mean = 0.
  stddev = 1.

  r = obj_new('MGanRandom')
  result = r->getGaussians(n, mean=mean, stddev=stddev, error=error)
  obj_destroy, r

  assert, error eq 0L, 'error %d retrieving data', error

  assert, size(result, /type) eq 4, $
          'incorrect type: %d', size(result, /type)
  assert, n_elements(result) eq n, $
          'incorrect number of values: %d', n_elements(result)
  assert, abs(mean(result) - mean) lt 0.3, $
          'incorrect mean: %f', mean(result)
  assert, abs(stddev(result) - stddev) lt 0.5, $
          'incorrect stddev: %f', stddev(result)

  return, 1
end


function mganrandom_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mganrandom__define', 'mganrandom::cleanup']
  self->addTestingRoutine, ['mganrandom::init', $
                            'mganrandom::getGaussians', $
                            'mganrandom::getIntegers', $
                            'mganrandom::getSequence', $
                            'mganrandom::_convertData', $
                            'mganrandom::_getData'], $
                           /is_function

  return, 1
end


pro mganrandom_ut__define
  compile_opt strictarr

  define = { mganrandom_ut, inherits MGutLibTestCase }
end

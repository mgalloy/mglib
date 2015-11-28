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


function mganrandom_ut::test_integers_error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    obj_destroy, r
    return, 1
  endif

  assert, mg_idlversion(require='6.4'), /skip, $
          'test requires IDL 6.4, %s present', !version.release

  assert, mg_connected(), /skip, $
          'must be connected to the Internet to use MGanRandom class'

  r = obj_new('MGanRandom')
  result = r->getIntegers()
  obj_destroy, r

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
  tolerance = 0.5

  r = obj_new('MGanRandom')
  result = r->getGaussians(n, mean=mean, stddev=stddev, error=error)
  obj_destroy, r

  assert, error eq 0L, 'error %d retrieving data', error

  assert, size(result, /type) eq 4, $
          'incorrect type: %d', size(result, /type)
  assert, n_elements(result) eq n, $
          'incorrect number of values: %d', n_elements(result)
  assert, abs(mean(result) - mean) lt tolerance, $
          'mean %0.2f not within tolerance %0.2f of 0.0', mean(result), tolerance
  assert, abs(stddev(result) - stddev) lt tolerance, $
          'stddev %0.2f not within tolerance %0.2f of 1.0', stddev(result), tolerance

  return, 1
end


function mganrandom_ut::test_gaussians_error
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    obj_destroy, r
    return, 1
  endif

  assert, mg_idlversion(require='6.4'), /skip, $
          'test requires IDL 6.4, %s present', !version.release

  assert, mg_connected(), /skip, $
          'must be connected to the Internet to use MGanRandom class'

  r = obj_new('MGanRandom')
  result = r->getGaussians()
  obj_destroy, r

  return, 1
end


function mganrandom_ut::test_sequence
  compile_opt strictarr

  assert, mg_idlversion(require='6.4'), /skip, $
          'test requires IDL 6.4, %s present', !version.release

  assert, mg_connected(), /skip, $
          'must be connected to the Internet to use MGanRandom class'

  minimum = 1
  maximum = 10

  r = obj_new('MGanRandom')
  result = r->getSequence(minimum=minimum, maximum=maximum, error=error)
  obj_destroy, r

  assert, error eq 0L, 'error %d retrieving data', error

  assert, size(result, /type) eq 3, $
          'incorrect type: %d', size(result, /type)
  assert, n_elements(result) eq maximum - minimum + 1L, $
          'incorrect number of values: %d', n_elements(result)
  assert, array_equal(histogram(result, min=minimum, max=maximum, nbins=maximum - minimum + 1L), $
                      lonarr(maximum - minimum + 1L) + 1L), $
          'not all values in sequence'

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

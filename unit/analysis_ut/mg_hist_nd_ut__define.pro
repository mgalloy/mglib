function mg_hist_nd_ut::test_2d
  compile_opt strictarr

  q = transpose([[0.1 * findgen(40)], [0.1 * findgen(40)]])
  result = mg_hist_nd(q, bin_size=1.)
  standard = 10L * long(identity(4))

  assert, size(result, /n_dimensions) eq 2, 'incorrect number of dimensions'
  assert, array_equal(size(result, /dimensions), [4, 4]), 'incorrect dimensions'
  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_hist_nd_ut::test_2d_weights
  compile_opt strictarr

  q = transpose([[0.1 * findgen(40)], [0.1 * findgen(40)]])
  weights = q * 0. + 0.1

  result = mg_hist_nd(q, bin_size=1., weights=weights, unweighted=unweighted)

  standard = identity(4)
  unweighted_standard = 10L * long(identity(4))

  assert, size(unweighted, /n_dimensions) eq 2, $
          'incorrect number of dimensions in unweighted result'
  assert, array_equal(size(unweighted, /dimensions), [4, 4]), $
          'incorrect dimensions in unweighted result'
  assert, array_equal(unweighted, unweighted_standard), $
          'incorrect result in unweighted result'

  assert, size(result, /n_dimensions) eq 2, 'incorrect number of dimensions'
  assert, array_equal(size(result, /dimensions), [4, 4]), 'incorrect dimensions'
  assert, total(abs(result - standard)) lt 1e-6, 'incorrect result'

  return, 1
end


function mg_hist_nd_ut::test_geo
  compile_opt strictarr

  lons  = [100.0, 105.0, 107.0, 110.0, 111.0, 112.0]
  lats  = [-85.0, -84.0, -83.0, -85.0, -84.0, -83.0]
  times = [  0.0,   2.0,   3.0,   6.0,   7.0,   8.0]
  pts = transpose([[lons], [lats], [times]])
  h = mg_hist_nd(pts, $
                 bin_size=[10.0, 10.0, 5.0], $
                 min=[0.0, -90.0, 0.0], $
                 max=[360.0, 90.0, 10.0], $
                 reverse_indices=ri)

  npts = total(h, /preserve_type)

  assert, npts eq n_elements(lons), $
          'incorrect number of points in histogram: %d', npts
  assert, h[10, 0, 0] eq 3L, 'invalid value for h[10, 0, 0]'
  assert, h[11, 0, 1] eq 3L, 'invalid value for h[11, 0, 1]'

  return, 1
end


pro mg_hist_nd_ut__define
  compile_opt strictarr

  define = { mg_hist_nd_ut, inherits MGutLibTestCase }
end

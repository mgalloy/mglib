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

  standard = long(identity(4))
  unweighted_standard = 10L * long(identity(4))

  assert, size(unweighted, /n_dimensions) eq 2, $
          'incorrect number of dimensions in unweighted result'
  assert, array_equal(size(unweighted, /dimensions), [4, 4]), $
          'incorrect dimensions in unweighted result'
  assert, array_equal(unweighted, unweighted_standard), $
          'incorrect result in unweighted result'

  assert, size(result, /n_dimensions) eq 2, 'incorrect number of dimensions'
  assert, array_equal(size(result, /dimensions), [4, 4]), 'incorrect dimensions'
  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


pro mg_hist_nd_ut__define
  compile_opt strictarr

  define = { mg_hist_nd_ut, inherits MGutLibTestCase }
end

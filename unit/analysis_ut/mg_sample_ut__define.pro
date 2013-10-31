function mg_sample_ut::test1
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  ; IDL random numbers changed in IDL 8.2.2
  if (mg_idlversion(require='8.2.2')) then begin
    standard = [8, 6, 0]
  endif else begin
    standard = [7, 1, 5]
  endelse

  result = mg_sample(10, 3, seed=0L)
  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_sample_ut::_test_checkprops, n, n_samples, n_iterations=n_iterations
  compile_opt strictarr

  _n_iterations = n_elements(n_iterations) eq 0L ? 10L : n_iterations

  for i = 0, _n_iterations - 1L do begin
    result = mg_sample(n, n_samples)

    assert, n_elements(result) eq n_samples, $
            'incorrect number of samples, %d, for MG_SAMPLE(%d, %d)', $
            n_elements(result), $
            n, $
            n_samples

    if (n_samples gt 0L) then begin
      u = uniq(result[sort(result)])
      assert, array_equal(u, lindgen(n_samples)), 'non-unique elements in sample'

      assert, min(result) ge 0L, 'negative indices found'
      assert, max(result) lt n, 'out-of-bound indices found'
    endif
  endfor

  return, 1
end


function mg_sample_ut::test2
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  n = 1000L
  n_samples = [0L, 1L, 20L, 500L, 999L, 1000L]
  n_iterations = 10L

  for i = 0L, n_elements(n_samples) - 1L do begin
    result = self->_test_checkprops(n, n_samples[i], n_iterations=n_iterations)
  endfor

  return, result
end


pro mg_sample_ut__define
  compile_opt strictarr

  define = { mg_sample_ut, inherits MGutLibTestCase }
end

; docformat = 'rst'


function mg_reduce_reverse_indices_ut::test_basic
  compile_opt strictarr

  seed = 0L
  n = 1000000L
  a = randomu(seed, n, /double)

  h = histogram(a, min=0.0D, max=0.9D, nbins=10, reverse_indices=ri)

  b = mg_reduce_reverse_indices(a, h, ri, 'total')
  squares = mg_reduce_reverse_indices(a ^ 2, h, ri, 'total')

  m = b / h
  sdev = sqrt(squares / (h - 1) - 2.0D * m * b / (h - 1L) + m^2 * h / (h - 1L))

  tolerance = 1e-5

  ; check mean and stddev for elements in bin 5:
  for i = 0L, n_elements(h) - 1L do begin
    els = a[ri[ri[i]:ri[i + 1] - 1]]

    std_mean = mean(els, /double)
    std_sdev = stddev(els, /double)
    assert, abs(m[i] - std_mean) lt tolerance, $
            'incorrect mean for bin %d: %f', i, m[i]
    assert, abs(sdev[i] - std_sdev) lt tolerance, $
            'incorrect standard deviation for bin %d: %f', i, sdev[i]
  endfor
  
  return, 1
end


pro mg_reduce_reverse_indices_ut__define
  compile_opt strictarr

  define = { mg_reduce_reverse_indices_ut, inherits MGutLibTestCase }
end


function mg_find_pattern_ut::test_basic
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  ; IDL random numbers changed in IDL 8.2.2
  if (mg_idlversion(require='8.2.2')) then begin
    pattern = [55, 2, 16, 82, 36]
    location = 193
  endif else begin
    pattern = [6, 80, 41, 42, 86]
    location = 761
  endelse

  n = 1000L
  seed = 0L
  d = long(100L * randomu(seed, n))

  result = mg_find_pattern(d, pattern)

  assert, n_elements(result) eq 1L, 'incorrect number of elements in result'
  assert, result eq location, 'incorrect result: %d', result

  return, 1
end


pro mg_find_pattern_ut__define
  compile_opt strictarr

  define = { mg_find_pattern_ut, inherits MGutLibTestCase }
end

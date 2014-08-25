function mg_glcm_ut::test_int
  compile_opt strictarr

  im = [[0B, 0B, 1B, 1B], $
        [0B, 0B, 1B, 1B], $
        [0B, 2B, 2B, 2B], $
        [2B, 2B, 3B, 3B]]

  result = mg_glcm(im, 1, 0)

  standard = [[2L, 2L, 1L, 0L], $
              [0L, 2L, 0L, 0L], $
              [0L, 0L, 3L, 1L], $
              [0L, 0L, 0L, 1L]]

  assert, array_equal(result[0:3, 0:3], standard, /no_typeconv), $
          'incorrect subset values'

  ind = where(result, count)
  assert, count eq 7, 'incorrect number of non-zero values'

  return, 1
end


pro mg_glcm_ut__define
  compile_opt strictarr

  define = { mg_glcm_ut, inherits MGutLibTestCase }
end

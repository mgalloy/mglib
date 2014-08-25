function mg_glcm_ut::test_basic
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

  assert, array_equal(result, standard, /no_typeconv), $
          'incorrect subset values'

  return, 1
end


function mg_glcm_ut::test_symmetric
  compile_opt strictarr

  im = [[0B, 0B, 1B, 1B], $
        [0B, 0B, 1B, 1B], $
        [0B, 2B, 2B, 2B], $
        [2B, 2B, 3B, 3B]]

  result = mg_glcm(im, 1, 0, /symmetric)

  standard = [[4L, 2L, 1L, 0L], $
              [2L, 4L, 0L, 0L], $
              [1L, 0L, 6L, 1L], $
              [0L, 0L, 1L, 2L]]

  assert, array_equal(result, standard, /no_typeconv), $
          'incorrect subset values'

  return, 1
end


function mg_glcm_ut::test_n_levels
  compile_opt strictarr

  im = [[0B, 0B, 1B, 1B], $
        [0B, 0B, 1B, 1B], $
        [0B, 2B, 2B, 2B], $
        [2B, 2B, 3B, 3B]]

  result = mg_glcm(im, 1, 0, n_levels=2)

  standard = [[6L, 1L], $
              [0L, 5L]]

  assert, array_equal(result, standard, /no_typeconv), $
          'incorrect subset values'

  return, 1
end


pro mg_glcm_ut__define
  compile_opt strictarr

  define = { mg_glcm_ut, inherits MGutLibTestCase }
end

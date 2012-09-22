function mg_checkerboard_ut::test1x1
  compile_opt strictarr

  checker1x1 = mg_checkerboard()
  answer = [[0B, 255B], [255B, 0B]]
  
  assert, array_equal(checker1x1, answer, /no_typeconv), $
          'incorrect checkerboard values'
  
  return, 1
end


function mg_checkerboard_ut::test2x2
  compile_opt strictarr

  checker2x2 = mg_checkerboard(block_size=2)
  answer = [[0B, 0B, 255B, 255B], $
            [0B, 0B, 255B, 255B], $
            [255B, 255B, 0B, 0B], $
            [255B, 255B, 0B, 0B]]
  
  assert, array_equal(checker2x2, answer, /no_typeconv), $
          'incorrect checkerboard values'
  
  return, 1
end


function mg_checkerboard_ut::test2x2_colors
  compile_opt strictarr

  checker2x2 = mg_checkerboard(block_size=2, colors=[35B, 100B])
  answer = [[35B, 35B, 100B, 100B], $
            [35B, 35B, 100B, 100B], $
            [100B, 100B, 35B, 35B], $
            [100B, 100B, 35B, 35B]]
  
  assert, array_equal(checker2x2, answer, /no_typeconv), $
          'incorrect checkerboard values'
  
  return, 1
end


pro mg_checkerboard_ut__define
  compile_opt strictarr
  
  define = { mg_checkerboard_ut, inherits MGutLibTestCase }
end
function mg_rgb2index_ut::test_black
  compile_opt strictarr

  assert, mg_rgb2index([0B, 0B, 0B]) eq 0L, 'incorrect value for black'
  
  return, 1
end


function mg_rgb2index_ut::test_single_color
  compile_opt strictarr

  assert, mg_rgb2index([100B, 50B, 75B]) eq '4b3264'x, $
          'incorrect value for color'
  
  return, 1
end


function mg_rgb2index_ut::test_several_colors
  compile_opt strictarr

  colors = mg_rgb2index(transpose([[0B, 0B, 0B], [100B, 50B, 75B]]))
  assert, array_equal(colors, ['000000'x, '4b3264'x]), $
          'incorrect value for array of colors'
  
  return, 1
end


pro mg_rgb2index_ut__define
  compile_opt strictarr
  
  define = { mg_rgb2index_ut, inherits MGutLibTestCase }
end
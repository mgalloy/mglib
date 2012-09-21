function vis_index2rgb_ut::test_black
  compile_opt strictarr

  assert, array_equal(vis_index2rgb('000000'x), [0B, 0B, 0B], /no_typeconv), $
          'incorrect value for black'
          
  return, 1
end


pro vis_index2rgb_ut__define
  compile_opt strictarr
  
  define = { vis_index2rgb_ut, inherits VISutTestCase }
end
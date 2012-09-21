function vis_makect_ut::test1
  compile_opt strictarr

  ct1 = vis_makect([vis_color('yellow')], [vis_color('blue')])
  assert, array_equal(reform(ct1[*, 0]), 255B - bindgen(256)), $
          'invalid red colors'
  assert, array_equal(ct1[*, 1], 255B - bindgen(256)), $
          'invalid green colors'
  assert, array_equal(ct1[*, 2], bindgen(256)), $
          'invalid blue colors'
          
  ct2 = vis_makect(vis_color('yellow'), vis_color('blue'), ncolors=16)
  ct3 = vis_makect([255, 255, 255], [255, 0, 0])
  ct4 = vis_makect(vis_color('red'), vis_color('white'), vis_color('green'), $
                   ncolors=32)
  ct5 = vis_makect(vis_color('powderblue'), vis_color('ivory'), vis_color('sienna'), $
                   ncolors=16)                  
                   
  return, 1
end


pro vis_makect_ut__define
  compile_opt strictarr
  
  define = { vis_makect_ut, inherits VISutTestCase }
end
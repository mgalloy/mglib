function mg_makect_ut::test1
  compile_opt strictarr

  ct1 = mg_makect([mg_color('yellow')], [mg_color('blue')])
  assert, array_equal(reform(ct1[*, 0]), 255B - bindgen(256)), $
          'invalid red colors'
  assert, array_equal(ct1[*, 1], 255B - bindgen(256)), $
          'invalid green colors'
  assert, array_equal(ct1[*, 2], bindgen(256)), $
          'invalid blue colors'

  ct2 = mg_makect(mg_color('yellow'), mg_color('blue'), ncolors=16)
  ct3 = mg_makect([255, 255, 255], [255, 0, 0])
  ct4 = mg_makect(mg_color('red'), $
                  mg_color('white'), $
                  mg_color('green'), $
                  ncolors=32)
  ct5 = mg_makect(mg_color('powderblue'), $
                  mg_color('ivory'), $
                  mg_color('sienna'), $
                  ncolors=16)

  return, 1
end


pro mg_makect_ut__define
  compile_opt strictarr

  define = { mg_makect_ut, inherits MGutLibTestCase }
end

function vis_tex2idl_ut::test1
  compile_opt strictarr

  tex = 'a^{b^c}'
  idl = ''
  
  assert, vis_tex2idl(tex) eq idl, 'incorrect result for ' + tex
  
  return, 1
end


function vis_tex2idl_ut::test2
  compile_opt strictarr

  tex = 'a_{b_c}'
  idl = ''
  
  assert, vis_tex2idl(tex) eq idl, 'incorrect result for ' + tex
  
  return, 1
end



function vis_tex2idl_ut::test3
  compile_opt strictarr

  tex = 'a^5_b'
  idl = ''
  
  assert, vis_tex2idl(tex) eq idl, 'incorrect result for ' + tex
  
  return, 1
end


function vis_tex2idl_ut::test4
  compile_opt strictarr

  tex = 'R_{0^{-}_{\delta F}1}'
  idl = 'R!D0!S!E-!R!I!7d!XF!N!D1!N'
  
  assert, vis_tex2idl(tex) eq idl, 'incorrect result for ' + tex
  
  return, 1
end



pro vis_tex2idl_ut__define
  compile_opt strictarr
  
  define = { vis_tex2idl_ut, inherits VISutTestCase }
end
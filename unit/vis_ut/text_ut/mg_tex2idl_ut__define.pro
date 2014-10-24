function mg_tex2idl_ut::test1
  compile_opt strictarr

  tex = 'a^{b^c}'
  idl = 'a!Ub!Ec!N'

  assert, mg_tex2idl(tex) eq idl, 'incorrect result for %s', tex

  return, 1
end


function mg_tex2idl_ut::test2
  compile_opt strictarr

  tex = 'a_{b_c}'
  idl = 'a!Db!Ic!N'

  assert, mg_tex2idl(tex) eq idl, 'incorrect result for %s', tex

  return, 1
end



function mg_tex2idl_ut::test3
  compile_opt strictarr

  tex = 'a^5_b'
  idl = 'a!S!U5!R!N!Db !N'

  assert, mg_tex2idl(tex) eq idl, 'incorrect result for %s', tex

  return, 1
end


function mg_tex2idl_ut::test4
  compile_opt strictarr

  tex = 'R_{0^{-}_{\delta F}1}'
  idl = 'R!D0!S!E-!R!I!7d!X F1!N'

  assert, mg_tex2idl(tex) eq idl, 'incorrect result for %s', tex

  return, 1
end


function mg_tex2idl_ut::init
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mg_tex2idl', $
                            'mg_textable', $
                            'mg_convert_fraction', $
                            'mg_convert_subsuper', $
                            'mg_token', $
                            'mg_nexttoken', $
                            'mg_strcnt', $
                            'mg_matchdelim', $
                            'mg_subsuper'], $
                           /is_function

  return, 1
end


pro mg_tex2idl_ut__define
  compile_opt strictarr

  define = { mg_tex2idl_ut, inherits MGutLibTestCase }
end

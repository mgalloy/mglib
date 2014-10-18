function mg_gradient_ut::test1
  compile_opt strictarr

  ; TODO: implement

  return, 1
end


function mg_gradient_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_gradient', /is_function

  return, 1
end


pro mg_gradient_ut__define
  compile_opt strictarr

  define = { mg_gradient_ut, inherits MGutLibTestCase }
end

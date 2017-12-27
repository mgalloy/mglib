; docformat = 'rst'

function mg_stregex_ut::test_simple
  compile_opt strictarr

  format = mg_format('%f')
  assert, format eq '(%"%f")', 'invalid format: ''%s''', format

  return, 1
end


function mg_format_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_format', /is_function

  return, 1
end


pro mg_format_ut__define
  compile_opt strictarr

  define = { mg_format_ut, inherits MGutLibTestCase }
end

; docformat = 'rst'

function mg_format_ut::test_simple
  compile_opt strictarr

  format = mg_format('%f')
  assert, format eq '(%"%f")', 'invalid format: ''%s''', format

  return, 1
end


function mg_format_ut::test_basic
  compile_opt strictarr

  format = mg_format('%*.*f', [0, 1])
  assert, format eq '(%"%0.1f")', 'invalid format: ''%s''', format

  return, 1
end


function mg_format_ut::test_escape
  compile_opt strictarr

  format = mg_format('%%%*.*f', [0, 1])
  assert, format eq '(%"%%%0.1f")', 'invalid format: ''%s''', format

  format = mg_format('%*.*f%%', [0, 1])
  assert, format eq '(%"%0.1f%%")', 'invalid format: ''%s''', format

  format = mg_format('%*.*f%%%*.*f', [0, 1, 0, 1])
  assert, format eq '(%"%0.1f%%%0.1f")', 'invalid format: ''%s''', format

  return, 1
end


function mg_format_ut::test_too_many1
  compile_opt strictarr
  @error_is_pass

  format = mg_format('%0.1f', 1)

  return, 0
end


function mg_format_ut::test_too_many2
  compile_opt strictarr
  @error_is_pass

  format = mg_format('%0.1f%%', 1)

  return, 0
end


function mg_format_ut::test_too_few1
  compile_opt strictarr
  @error_is_pass

  format = mg_format('%*.*f', 0)

  return, 0
end


function mg_format_ut::test_too_few2
  compile_opt strictarr
  @error_is_pass

  format = mg_format('%*d')

  return, 0
end


function mg_format_ut::test_too_few3
  compile_opt strictarr
  @error_is_pass

  format = mg_format('%*.0d')

  return, 0
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

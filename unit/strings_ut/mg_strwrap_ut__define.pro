; docformat = 'rst'

function mg_strwrap_ut::test_basic
  compile_opt strictarr

  result = mg_strwrap('Mike wasn''t here', width=4)

  assert, n_elements(result) eq 3L, 'incorrect number of lines'

  assert, result[0] eq 'Mike', 'incorrect first line'
  assert, result[1] eq 'wasn''t', 'incorrect second line'
  assert, result[2] eq 'here', 'incorrect third line'

  return, 1
end


function mg_strwrap_ut::test_indenting
  compile_opt strictarr

  s = 'The string to have leading and/or trailing blanks removed'
  result = mg_strwrap(s, width=12, indent=2, first_indent=0)

  assert, n_elements(result) eq 7L, 'incorrect number of lines'

  assert, result[0] eq 'The string', 'incorrect first line'
  assert, result[1] eq '  to have', 'incorrect second line'
  assert, result[2] eq '  leading', 'incorrect third line'
  assert, result[3] eq '  and/or', 'incorrect fourth line'
  assert, result[4] eq '  trailing', 'incorrect fifth line'
  assert, result[5] eq '  blanks', 'incorrect sixth line'
  assert, result[6] eq '  removed', 'incorrect seventh line'

  return, 1
end


function mg_strwrap_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_strwrap', /is_function

  return, 1
end


pro mg_strwrap_ut__define
  compile_opt strictarr

  define = { mg_strwrap_ut, inherits MGutLibTestCase }
end

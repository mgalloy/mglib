; docformat = 'rst'

function mg_streplace_ut::test_basic
  compile_opt strictarr

  result = mg_streplace('Mike was here', 'was', 'was not')

  assert, result eq 'Mike was not here', 'incorrect result: ''' + result + ''''

  return, 1
end


function mg_streplace_ut::test_metavariables
  compile_opt strictarr

  result = mg_streplace('Mike was here', '([^ ]*) ([^ ]*)', '$2 $1')

  assert, result eq 'was Mike here', 'incorrect result: ''' + result + ''''

  return, 1
end


function mg_streplace_ut::test_evaluate1
  compile_opt strictarr

  s = 'MikeGeorgeHenryMikeBill'
  re = 'Mike([A-Z][a-z]*)'
  expr = '"Mike" + strupcase($1)'
  result = mg_streplace(s, re, expr, /evaluate, /global)

  assert, result eq 'MikeGEORGEHenryMikeBILL', $
          'incorrect result: ''' + result + ''''

  return, 1
end


function mg_streplace_ut::test_evaluate2
  compile_opt strictarr

  re = 'Mike([0-9]+)'
  expr = 'fix($1) * 2'
  result = mg_streplace('Mike5', re, expr, /evaluate)
  assert, result eq 10L, 'incorrect result: ' + strtrim(result, 2)

  return, 1
end


function mg_streplace_ut::test_commas
  compile_opt strictarr

  str = '1874382735872851'
  re = '^[+-]?([[:digit:]]+)([[:digit:]]{3})'
  for i = 0, strlen(str) / 3 - 1 do begin
     str = mg_streplace(str, re, '$1,$2', /global)
  endfor

  assert, str eq '1,874,382,735,872,851', 'incorrect result: ''' + str + ''''

  return, 1
end


function mg_streplace_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_streplace', /is_function

  return, 1
end


pro mg_streplace_ut__define
  compile_opt strictarr

  define = { mg_streplace_ut, inherits MGutLibTestCase }
end

; docformat = 'rst'


function mg_resolve_routine_ut::test_found
  compile_opt strictarr

  mg_resolve_routine, 'assert', resolved=resolved
  assert, resolved, 'ASSERT not found'

  return, 1
end


function mg_resolve_routine_ut::test_resolve_itself
  compile_opt strictarr

  mg_resolve_routine, 'mg_resolve_routine', resolved=resolved
  assert, resolved, 'mg_resolve_routine not found'

  return, 1
end


function mg_resolve_routine_ut::test_notfound
  compile_opt strictarr

  mg_resolve_routine, 'mg_resolve_routine_nonexistent', resolved=resolved
  assert, ~resolved, 'mg_resolve_routine_nonexistent found'

  return, 1
end


;+
; Define member variables.
;-
pro mg_resolve_routine_ut__define
	compile_opt strictarr

	define = { mg_resolve_routine_ut, inherits MGutLibTestCase }
end
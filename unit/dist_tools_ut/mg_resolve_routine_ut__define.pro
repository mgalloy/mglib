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


function mg_cmp_version_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mg_cmp_version', $
                            'mg_cmp_version_decompose', $
                            'mg_cmp_version_cmp', $
                            'mg_cmp_version_isinteger'], $
                           /is_function

  return, 1
end


;+
; Define member variables.
;-
pro mg_resolve_routine_ut__define
	compile_opt strictarr

	define = { mg_resolve_routine_ut, inherits MGutLibTestCase }
end

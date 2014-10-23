; docformat = 'rst'

function mg_subs_ut::test_basic
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  h = hash(['name', 'location'], ['Mike', 'Boulder'])

  value = mg_subs('%(name)s lives in %(location)s', h)
  assert, value eq 'Mike lives in Boulder', 'incorrect value: %s', value

  obj_destroy, h

  return, 1
end


function mg_subs_ut::test_derived
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  h = hash(['firstname', 'lastname', 'name', 'location'], $
           ['Mike', 'Galloy', '%(firstname)s %(lastname)s', 'Boulder'])

  value = mg_subs('%(name)s lives in %(location)s', h)
  assert, value eq 'Mike Galloy lives in Boulder', 'incorrect value: %s', value

  obj_destroy, h

  return, 1
end


function mg_subs_ut::test_derived2
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  h = hash(['first', 'firstname', 'lastname', 'name', 'location'], $
           ['Mike', '%(first)s', 'Galloy', '%(firstname)s %(lastname)s', 'Boulder'])

  value = mg_subs('%(name)s lives in %(location)s', h)
  assert, value eq 'Mike Galloy lives in Boulder', 'incorrect value: %s', value

  obj_destroy, h

  return, 1
end


function mg_subs_ut::test_derived_perverse
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  h = hash(['firstname1', 'firstname2', 'firstname', 'lastname', 'name', 'location'], $
           ['%(first', 'name)s', 'Mike', 'Galloy', '%(firstname1)s%(firstname2)s %(lastname)s', 'Boulder'])

  value = mg_subs('%(name)s lives in %(location)s', h)
  assert, value eq 'Mike Galloy lives in Boulder', 'incorrect value: %s', value

  obj_destroy, h

  return, 1
end


function mg_subs_ut::test_not_found
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  h = hash(['location'], ['Boulder'])

  value = mg_subs('%(name)s lives in %(location)s', h)
  assert, value eq '%(name)s lives in Boulder', 'incorrect value: %s', value

  obj_destroy, h

  return, 1
end


function mg_subs_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mg_subs', $
                            'mg_subs_iter', $
                            'mg_subs_getvalue'], $
                           /is_function

  return, 1
end


pro mg_subs_ut__define
  compile_opt strictarr

  define = { mg_subs_ut, inherits MGutLibTestCase }
end

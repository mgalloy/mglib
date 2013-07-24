; docformat = 'rst'

function mg_subs_ut::test_basic
  compile_opt strictarr

  h = hash(['name', 'location'], ['Mike', 'Boulder'])

  value = mg_subs('%(name)s lives in %(location)s', h)
  assert, value eq 'Mike lives in Boulder', 'incorrect value: %s', value

  obj_destroy, h

  return, 1
end


function mg_subs_ut::test_derived
  compile_opt strictarr

  h = hash(['firstname', 'lastname', 'name', 'location'], $
           ['Mike', 'Galloy', '%(firstname)s %(lastname)s', 'Boulder'])

  value = mg_subs('%(name)s lives in %(location)s', h)
  assert, value eq 'Mike Galloy lives in Boulder', 'incorrect value: %s', value

  obj_destroy, h

  return, 1
end


function mg_subs_ut::test_derived2
  compile_opt strictarr

  h = hash(['first', 'firstname', 'lastname', 'name', 'location'], $
           ['Mike', '%(first)s', 'Galloy', '%(firstname)s %(lastname)s', 'Boulder'])

  value = mg_subs('%(name)s lives in %(location)s', h)
  assert, value eq 'Mike Galloy lives in Boulder', 'incorrect value: %s', value

  obj_destroy, h

  return, 1
end


function mg_subs_ut::test_derived_perverse
  compile_opt strictarr

  h = hash(['firstname1', 'firstname2', 'firstname', 'lastname', 'name', 'location'], $
           ['%(first', 'name)s', 'Mike', 'Galloy', '%(firstname1)s%(firstname2)s %(lastname)s', 'Boulder'])

  value = mg_subs('%(name)s lives in %(location)s', h)
  assert, value eq 'Mike Galloy lives in Boulder', 'incorrect value: %s', value

  obj_destroy, h

  return, 1
end


function mg_subs_ut::test_not_found
  compile_opt strictarr

  h = hash(['location'], ['Boulder'])

  value = mg_subs('%(name)s lives in %(location)s', h)
  assert, value eq '%(name)s lives in Boulder', 'incorrect value: %s', value

  obj_destroy, h

  return, 1
end


pro mg_subs_ut__define
  compile_opt strictarr

  define = { mg_subs_ut, inherits MGutLibTestCase }
end

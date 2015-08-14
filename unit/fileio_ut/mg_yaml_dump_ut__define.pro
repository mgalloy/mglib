; docformat = 'rst'

; workaround: bug in IDL which keeps pointers to undefined variables
; corresponding to removed elements of a list (but doesn't happend on the
; command line)
pro mg_yaml_dump_ut::teardown
  compile_opt strictarr
end


function mg_yaml_dump_ut::test_basic
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  o = list(hash('a', 1, 'b', 2), hash('c', 3, 'd', 4), list(1, 2, 3))

  result = mg_yaml_dump(o)
  standard = ['- a: 1', '  b: 2', '- c: 3', '  d: 4', '- - 1', '  - 2', '  - 3']

  assert, result eq mg_strmerge(standard), 'incorrect result'

  mg_yaml_free, o

  return, 1
end


function mg_yaml_dump_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mg_yaml_dump', $
                            'mg_yaml_dump_islist', $
                            'mg_yaml_dump_firstindent', $
                            'mg_yaml_dump_hashelement', $
                            'mg_yaml_dump_hashkey', $
                            'mg_yaml_dump_hashkeys', $
                            'mg_yaml_dump_ishash'], $
                           /is_function
  self->addTestingRoutine, ['mg_yaml_dump_level']

  return, 1
end



;+
; Test `MG_READ_CONFIG`.
;-
pro mg_yaml_dump_ut__define
  compile_opt strictarr

  define = { mg_yaml_dump_ut, inherits MGutLibTestCase }
end

; docformat = 'rst'

;+
; Setup before each test is run.
;-
pro mg_options_ut::setup
  compile_opt strictarr

end


;+
; Cleanup after each test is run.
;-
pro mg_options_ut::teardown
  compile_opt strictarr

end


function mg_options_ut::test_longForms
  compile_opt strictarr

  ; create options object
  opts = obj_new('mg_options')

  ; setup options
  opts->addOption, 'verbose', 'v', $
                   /boolean, $
                   help='set to print a verbose greeting'
  opts->addOption, 'name', help='name of user to greet', default='Mike'

  ; parse the options
  opts->parseArgs, ['--verbose']

  assert, opts->get('verbose'), 'verbose should be set'

  obj_destroy, opts

  return, 1
end


;+
; Define instance variables.
;-
pro mg_options_ut__define
  compile_opt strictarr

  define = { mg_options_ut, inherits MGutLibTestCase }
end

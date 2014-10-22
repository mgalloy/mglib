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


function mg_options_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mg_options__define', $
                            'mg_options::cleanup', $
                            'mg_options::addParams', $
                            'mg_options::addOption', $
                            'mg_options::parseArgs', $
                            'mg_options::_displayVersion', $
                            'mg_options::_displayHelp', $
                            'mg_opt__define', $
                            'mg_opt::setValue', $
                            'mg_opt::getProperty', $
                            'mg_opt::setProperty']
  self->addTestingRoutine, ['mg_options::init', $
                            'mg_options::get', $
                            'mg_opt::init', $
                            'mg_opt::getValue', $
                            'mg_opt::getHelp', $
                            'mg_opt::isPresent'], $
                           /is_function

  return, 1
end


;+
; Define instance variables.
;-
pro mg_options_ut__define
  compile_opt strictarr

  define = { mg_options_ut, inherits MGutLibTestCase }
end

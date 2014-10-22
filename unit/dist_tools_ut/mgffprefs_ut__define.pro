; docformat = 'rst'

;+
; Setup before each test is run.
;-
pro mgffprefs_ut::setup
  compile_opt strictarr

  file_delete, file_dirname(file_dirname(self.configdir)), $
               /recursive, /allow_nonexistent, /quiet
end


;+
; Cleanup after each test is run.
;-
pro mgffprefs_ut::teardown
  compile_opt strictarr

  file_delete, file_dirname(file_dirname(self.configdir)), $
               /recursive, /allow_nonexistent, /quiet
end


function mgffprefs_ut::test_error1
  compile_opt strictarr
  @error_is_pass

  prefs = obj_new('mgffprefs')

  return, 0
end


function mgffprefs_ut::test_error2
  compile_opt strictarr
  @error_is_pass

  prefs = obj_new('mgffprefs', author=self.author)

  return, 0
end


function mgffprefs_ut::test_error3
  compile_opt strictarr
  @error_is_pass

  prefs = obj_new('mgffprefs', application=self.application)

  return, 0
end


function mgffprefs_ut::test_default
  compile_opt strictarr

  prefs = obj_new('mgffprefs', author_name=self.author, app_name=self.application)
  name = prefs->get('name', default='Elizabeth')
  obj_destroy, prefs

  assert, name eq 'Elizabeth', $
          string(name, format='(%"unset name %s does not match the default")')

  return, 1
end


function mgffprefs_ut::test_string
  compile_opt strictarr

  prefs = obj_new('mgffprefs', author_name=self.author, app_name=self.application)
  prefs->set, 'name', 'Michael'
  obj_destroy, prefs

  prefs = obj_new('mgffprefs', author_name=self.author, app_name=self.application)
  name = prefs->get('name', found=found)
  obj_destroy, prefs

  assert, found eq 1B, 'preference not found'
  assert, name eq 'Michael', 'preference name does not match'

  return, 1
end


function mgffprefs_ut::test_noPrefname
  compile_opt strictarr

  prefs = obj_new('mgffprefs', author_name=self.author, app_name=self.application)
  prefs->set, 'name', 'Michael'
  obj_destroy, prefs

  prefs = obj_new('mgffprefs', author_name=self.author, app_name=self.application)
  name = prefs->get(found=found)
  obj_destroy, prefs

  assert, found eq 0B, 'preference should not found'
  assert, name eq -1L, 'invalid value for invalid preference name'

  return, 1
end


function mgffprefs_ut::test_badPrefname
  compile_opt strictarr

  prefname = '1name &%'

  prefs = obj_new('mgffprefs', author_name=self.author, app_name=self.application)
  prefs->set, prefname, 'Michael'
  obj_destroy, prefs

  prefs = obj_new('mgffprefs', author_name=self.author, app_name=self.application)
  name = prefs->get(prefname, found=found)
  prefnames = prefs->get(/names)
  obj_destroy, prefs

  assert, found eq 1B, 'preference not found'
  assert, name eq 'Michael', 'preference name does not match'
  assert, prefnames eq '_1name___', 'invalid correction of name: ' + prefnames
  return, 1
end


function mgffprefs_ut::test_nonames
  compile_opt strictarr

  prefs = obj_new('mgffprefs', author_name=self.author, app_name=self.application)
  names = prefs->get(found=found, /names)
  obj_destroy, prefs

  assert, found eq 0B, 'FOUND set when it should not be'
  assert, names eq -1L, 'invalid names when none found'

  return, 1
end


function mgffprefs_ut::test_names
  compile_opt strictarr

  correct_names = ['age', 'dob', 'name']

  prefs = obj_new('mgffprefs', author_name=self.author, app_name=self.application)
  prefs->set, 'name', 'Michael'
  prefs->set, 'age', 38
  prefs->set, 'DOB', 'February 23rd'
  names = prefs->get(found=found, /names)
  obj_destroy, prefs

  assert, found eq 1B, 'FOUND not set when it should be'
  assert, array_equal(names, correct_names), $
          'invalid names: ' + strjoin(strtrim(names, 2), ', ')

  return, 1
end


function mgffprefs_ut::test_clear
  compile_opt strictarr

  prefs = obj_new('mgffprefs', author_name=self.author, app_name=self.application)

  prefs->set, 'name', 'Michael'
  name = prefs->get('name', found=found1)

  prefs->clear, 'name'
  name = prefs->get('name', found=found2)

  prefs->clear, 'name'

  obj_destroy, prefs

  assert, found1 eq 1B, 'name not found when it should be'
  assert, found2 eq 0B, 'name found when it should not be'

  return, 1
end


function mgffprefs_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self.author = 'mgffprefs_ut'
  self.application = 'mgffprefs_ut'

  appdir = app_user_dir(self.author, 'Author description', $
                        self.application, 'Application description', $
                        'Readme text', 1)
  self.configdir = filepath('', subdir='prefs', root=appdir)

  self->addTestingRoutine, ['mgffprefs__define', $
                            'mgffprefs::cleanup', $
                            'mgffprefs::getProperty', $
                            'mgffprefs::clear', $
                            'mgffprefs::set']
  self->addTestingRoutine, ['mgffprefs::init', $
                            'mgffprefs::_getAppDir', $
                            'mgffprefs::_prefnameToFilename', $
                            'mgffprefs::get'], $
                           /is_function

  return, 1
end


;+
; Define instance variables.
;-
pro mgffprefs_ut__define
  compile_opt strictarr

  define = { mgffprefs_ut, inherits MGutLibTestCase, $
             author: '', $
             application: '', $
             configdir: '' }
end

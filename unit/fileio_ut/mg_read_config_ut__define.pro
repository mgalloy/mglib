; docformat = 'rst'

function mg_read_config_ut::test_basic
  compile_opt strictarr

  config_filename = filepath('simple_config.ini', root=mg_src_root())
  assert, file_test(config_filename), 'test configuration file not found', /skip

  config = mg_read_config(config_filename, error=err)
  assert, err eq 0L, 'error reading configuration file: %d', err

  assert, config.has_option('dir'), 'dir value not present'
  assert, config['dir'] eq 'frob', $
          'invalid value for dir: %s', config['dir']

  assert, config.has_option('long'), 'long value not present'
  assert, config['long'] eq 'this value continues in the next line', $
          'invalid value for long: %s', config['long']

  obj_destroy, config

  return, 1
end


function mg_read_config_ut::test_basic_sections
  compile_opt strictarr

  config_filename = filepath('config.ini', root=mg_src_root())
  assert, file_test(config_filename), 'test configuration file not found', /skip

  config = mg_read_config(config_filename, error=err)
  assert, err eq 0L, 'error reading configuration file: %d', err

  assert, config.has_option('dir', section='My section'), 'dir value not present'
  assert, config->get('dir', section='My section') eq 'frob', $
          'invalid value for dir: %s', config->get('dir', section='My section')

  assert, config.has_option('long'), 'long value not present'
  assert, config->get('long', section='My section') eq 'this value continues in the next line', $
          'invalid value for long: %s', config->get('long', section='My section')

  obj_destroy, config

  return, 1
end


function mg_read_config_ut::test_substitution
  compile_opt strictarr

  config_filename = filepath('config.ini', root=mg_src_root())
  assert, file_test(config_filename), 'test configuration file not found', /skip

  config = mg_read_config(config_filename, error=err)
  assert, err eq 0L, 'error reading configuration file: %d', err

  assert, config.has_option('foodir'), 'foodir value not present'
  assert, config['foodir'] eq 'frob/whatever', $
          'invalid value for foodir: %s', config['foodir']

  obj_destroy, config

  return, 1
end


function mg_read_config_ut::test_defaults
  compile_opt strictarr

  config_filename = filepath('config.ini', root=mg_src_root())
  assert, file_test(config_filename), 'test configuration file not found', /skip

  defaults = hash('default1', 'default value 1', 'dir', 'not frob')

  config = mg_read_config(config_filename, error=err, defaults=defaults)
  assert, err eq 0L, 'error reading configuration file: %d', err

  assert, config.has_option('default1'), 'default1 value not present'
  assert, config['default1'] eq 'default value 1', $
         'invalid value for default1: %s', config['default1']

  assert, config.has_option('dir'), 'dir value not present'
  assert, config['dir'] eq 'frob', $
          'invalid value for dir: %s', config['dir']

  assert, config.has_option('long'), 'long value not present'
  assert, config['long'] eq 'this value continues in the next line', $
          'invalid value for long: %s', config['long']

  obj_destroy, [defaults, config]

  return, 1
end


;+
; Test array list.
;-
pro mg_read_config_ut__define
  compile_opt strictarr

  define = { mg_read_config_ut, inherits MGutLibTestCase }
end

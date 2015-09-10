; docformat = 'rst'

function mg_read_config_ut::test_basic
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  config_filename = filepath('simple_config.ini', root=mg_src_root())
  assert, file_test(config_filename), 'test configuration file not found', /skip

  config = mg_read_config(config_filename, error=err)
  assert, err eq 0L, 'error reading configuration file: %d', err

  assert, config->has_option('dir'), 'dir value not present'
  assert, config['dir'] eq 'frob', $
          'invalid value for dir: %s', config['dir']

  assert, config->has_option('long'), 'long value not present'
  assert, config['long'] eq 'this value continues in the next line', $
          'invalid value for long: %s', config['long']

  obj_destroy, config

  return, 1
end


function mg_read_config_ut::test_sections_basic
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  config_filename = filepath('config.ini', root=mg_src_root())
  assert, file_test(config_filename), 'test configuration file not found', /skip

  config = mg_read_config(config_filename, error=err)
  assert, err eq 0L, 'error reading configuration file: %d', err

  section_name = 'My Section'
  assert, config->has_option('dir', section=section_name), 'dir value not present'
  assert, config->get('dir', section=section_name) eq 'frob', $
          'invalid value for dir: %s', config->get('dir', section=section_name)

  assert, config->has_option('other', section=section_name), 'other value not present'
  assert, config->get('other', section=section_name) eq 'value', $
          'invalid value for other: %s', config->get('other', section=section_name)

  assert, config->has_option('long', section=section_name), 'long value not present'
  assert, config->get('long', section=section_name) eq 'this value continues in the next line', $
          'invalid value for long: %s', config->get('long', section=section_name)

  obj_destroy, config

  return, 1
end


function mg_read_config_ut::test_substitution
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  config_filename = filepath('simple_config.ini', root=mg_src_root())
  assert, file_test(config_filename), 'test configuration file not found', /skip

  config = mg_read_config(config_filename, error=err)
  assert, err eq 0L, 'error reading configuration file: %d', err

  assert, config->has_option('foodir'), 'foodir value not present'
  assert, config['foodir'] eq 'frob/whatever', $
          'invalid value for foodir: %s', config['foodir']

  obj_destroy, config

  return, 1
end


function mg_read_config_ut::test_substitution_multiple
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  config_filename = filepath('simple_config.ini', root=mg_src_root())
  assert, file_test(config_filename), 'test configuration file not found', /skip

  config = mg_read_config(config_filename, error=err)
  assert, err eq 0L, 'error reading configuration file: %d', err

  assert, config->has_option('derived'), 'derived value not present'
  assert, config['derived'] eq 'frob/whatever/extra', $
          'invalid value for derived: %s', config['derived']

  assert, config->has_option('derived2'), 'derived2 value not present'
  assert, config['derived2'] eq 'frob/whatever/extra/more', $
          'invalid value for derived2: %s', config['derived2']

  obj_destroy, config

  return, 1
end


function mg_read_config_ut::test_defaults_options
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  config_filename = filepath('simple_config.ini', root=mg_src_root())
  assert, file_test(config_filename), 'test configuration file not found', /skip

  defaults = mgffoptions()
  defaults->put, 'default1', 'default value 1'
  defaults->put, 'dir', 'not frob'

  config = mg_read_config(config_filename, error=err, defaults=defaults)
  assert, err eq 0L, 'error reading configuration file: %d', err

  assert, config->has_option('default1'), 'default1 value not present'
  assert, config['default1'] eq 'default value 1', $
         'invalid value for default1: %s', config['default1']

  assert, config->has_option('dir'), 'dir value not present'
  assert, config['dir'] eq 'frob', $
          'invalid value for dir: %s', config['dir']

  assert, config->has_option('long'), 'long value not present'
  assert, config['long'] eq 'this value continues in the next line', $
          'invalid value for long: %s', config['long']

  obj_destroy, [defaults, config]

  return, 1
end


function mg_read_config_ut::test_defaults_hash
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  config_filename = filepath('simple_config.ini', root=mg_src_root())
  assert, file_test(config_filename), 'test configuration file not found', /skip

  defaults = hash('default1', 'default value 1', 'dir', 'not frob')

  config = mg_read_config(config_filename, error=err, defaults=defaults)
  assert, err eq 0L, 'error reading configuration file: %d', err

  assert, config->has_option('default1'), 'default1 value not present'
  assert, config['default1'] eq 'default value 1', $
         'invalid value for default1: %s', config['default1']

  assert, config->has_option('dir'), 'dir value not present'
  assert, config['dir'] eq 'frob', $
          'invalid value for dir: %s', config['dir']

  assert, config->has_option('long'), 'long value not present'
  assert, config['long'] eq 'this value continues in the next line', $
          'invalid value for long: %s', config['long']

  obj_destroy, [defaults, config]

  return, 1
end


function mg_read_config_ut::test_sections_advanced
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  config_filename = filepath('sections.ini', root=mg_src_root())
  assert, file_test(config_filename), 'test configuration file not found', /skip

  config = mg_read_config(config_filename, error=err, defaults=defaults)

  terra_data = config->get('data', section='Terra')
  assert, terra_data eq '~/data/MODIS/Terra/C5', $
          'incorrect value for Terra data: %s', terra_data

  obj_destroy, config

  return, 1
end


function mg_read_config_ut::test_extract
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  config_filename = filepath('sections.ini', root=mg_src_root())
  assert, file_test(config_filename), 'test configuration file not found', /skip

  config = mg_read_config(config_filename, error=err, defaults=defaults)

  terra_variables = config->get('variables', section='Terra', /extract, count=count)
  terra_standard = ['Longitude', 'Latitude', 'Optical_Depth_Land_And_Ocean']
  assert, count eq 3L, 'incorrect count for Aqua variables: %d', count
  assert, array_equal(terra_standard, terra_variables), 'incorrect Terra variables'

  aqua_variables = config->get('variables', section='Aqua', /extract, count=count)
  aqua_standard = [ 'Longitude', 'Latitude', 'Deep_Blue_Angstrom_Exponent_Land' ]
  assert, count eq 3L, 'incorrect count for Aqua variables: %d', count
  assert, array_equal(aqua_standard, aqua_variables), 'incorrect Aqua variables'

  obj_destroy, config

  return, 1
end


function mg_read_config_ut::test_case
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  config_filename = filepath('sections.ini', root=mg_src_root())
  assert, file_test(config_filename), 'test configuration file not found', /skip

  config = mg_read_config(config_filename, error=err, defaults=defaults, /fold_case)

  assert, config->has_option('grid', section='aqua'), $
          'grid option in aqua section not found'
  value = config->get('grid', section='aqua')
  assert, value eq '~/data/MODIS/Aqua/C5/grids/MERRA-125x1.25.nc', $
          'incorrect value for grid option in aqua section: %s', value

  obj_destroy, config

  return, 1
end


function mg_read_config_ut::test_boolean1
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  config_filename = filepath('config.ini', root=mg_src_root())
  assert, file_test(config_filename), 'test configuration file not found', /skip

  config = mg_read_config(config_filename, error=err, defaults=defaults, /fold_case)

  v1 = config->get('bool_value1', section='My Section', /boolean)
  v2 = config->get('bool_value2', section='My Section', /boolean)
  v3 = config->get('bool_value3', section='My Section', /boolean, default=1B)
  v4 = config->get('bool_value4', section='My Section', /boolean, default=0B)
  v5 = config->get('bool_value5', section='My Section', /boolean, default=1B)

  assert, size(v1, /type) eq 1, $
          'incorrect type for bool_value1: %d', size(v1, /type)
  assert, size(v2, /type) eq 1, $
          'incorrect type for bool_value2: %d', size(v2, /type)
  assert, size(v3, /type) eq 1, $
          'incorrect type for bool_value3: %d', size(v3, /type)
  assert, size(v4, /type) eq 1, $
          'incorrect type for bool_value4: %d', size(v4, /type)
  assert, size(v5, /type) eq 1, $
          'incorrect type for bool_value5: %d', size(v5, /type)

  assert, v1 eq 1, 'incorrect value for bool_value1: %d', v1
  assert, v2 eq 1, 'incorrect value for bool_value2: %d', v2
  assert, v3 eq 1, 'incorrect value for bool_value3: %d', v3
  assert, v4 eq 0, 'incorrect value for bool_value4: %d', v3
  assert, v5 eq 0, 'incorrect value for bool_value5: %d', v3

  obj_destroy, config

  return, 1
end


function mg_read_config_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mgffoptions__define', $
                            'mgffoptions::cleanup', $
                            'mgffoptions::put', $
                            'mgffoptions::getProperty', $
                            'mgffoptions::_overloadBracketsLeftSide']
  self->addTestingRoutine, ['mg_read_config', $
                            'mgffoptions::init', $
                            'mgffoptions::get', $
                            'mgffoptions::options', $
                            'mgffoptions::has_option', $
                            'mgffoptions::has_section', $
                            'mgffoptions::_overloadPrint', $
                            'mgffoptions::_overloadHelp', $
                            'mgffoptions::_overloadForeach', $
                            'mgffoptions::_overloadBracketsRightSide'], $
                           /is_function

  return, 1
end



;+
; Test `MG_READ_CONFIG`.
;-
pro mg_read_config_ut__define
  compile_opt strictarr

  define = { mg_read_config_ut, inherits MGutLibTestCase }
end

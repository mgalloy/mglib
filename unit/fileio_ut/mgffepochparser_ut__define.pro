; docformat = 'rst'

function mgffepochparser_ut::test_basic
  compile_opt strictarr

  epochs_filename = filepath('epochs.cfg', root=mg_src_root())
  spec_filename = filepath('epochs_spec.cfg', root=mg_src_root())

  epochs = mgffepochparser(epochs_filename, spec_filename)

  dt = '20171231.000000'
  version = epochs->get('cal_version', datetime=dt)
  type = size(version, /type)
  assert, type eq 2, 'incorrect type: %d', type
  assert, version eq 0, 'incorrect value %d @ datetime %s', version, dt

  dt = '20180101.000000'
  version = epochs->get('cal_version', datetime=dt)
  type = size(version, /type)
  assert, type eq 2, 'incorrect type: %d', type
  assert, version eq 1, 'incorrect value %d @ datetime %s', version, dt

  dt = '20180101.090000'
  version = epochs->get('cal_version', datetime=dt)
  type = size(version, /type)
  assert, type eq 2, 'incorrect type: %d', type
  assert, version eq 2, 'incorrect value %d @ datetime %s', version, dt

  dt = '20180130'
  version = epochs->get('cal_version', datetime=dt)
  type = size(version, /type)
  assert, type eq 2, 'incorrect type: %d', type
  assert, version eq 3, 'incorrect value %d @ datetime %s', version, dt

  obj_destroy, epochs

  return, 1B
end


function mgffepochparser_ut::test_valid
  compile_opt strictarr

  epochs_filename = filepath('epochs.cfg', root=mg_src_root())
  spec_filename = filepath('epochs_spec.cfg', root=mg_src_root())

  epochs = mgffepochparser(epochs_filename, spec_filename)
  assert, epochs->is_valid(), 'valid epoch/spec marked invalid'
  obj_destroy, epochs

  return, 1B
end


function mgffepochparser_ut::test_invalid
  compile_opt strictarr

  epochs_filename = filepath('missing_epoch.cfg', root=mg_src_root())
  spec_filename = filepath('epochs_spec.cfg', root=mg_src_root())

  epochs = mgffepochparser(epochs_filename, spec_filename)
  assert, ~epochs->is_valid(), 'invalid epoch/spec marked valid: %s', $
          file_basename(epochs_filename)
  obj_destroy, epochs

  epochs_filename = filepath('missing_default_epoch.cfg', root=mg_src_root())

  epochs = mgffepochparser(epochs_filename, spec_filename)
  assert, ~epochs->is_valid(), 'invalid epoch/spec marked valid: %s', $
          file_basename(epochs_filename)
  obj_destroy, epochs

  return, 1B
end


function mgffepochparser_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mgffepochparser__define', $
                            'mgffepochparser::cleanup', $
                            'mgffepochparser::getProperty', $
                            'mgffepochparser::setProperty']
  self->addTestingRoutine, ['mgffepochparser::init', $
                            'mgffepochparser::get', $
                            'mgffepochparser::is_valid', $
                            'mg_epoch_parse_datetime'], $
                           /is_function

  return, 1
end

pro mgffepochparser_ut__define
  compile_opt strictarr

  define = { mgffepochparser_ut, inherits MGutLibTestCase }
end

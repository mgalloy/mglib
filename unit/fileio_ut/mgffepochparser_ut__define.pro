; docformat = 'rst'

function mgffepochparser_ut::test_basic
  compile_opt strictarr

  ; TODO: test
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


function mgffepochparser_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mgffepochparser__define', $
                            'mgffepochparser::cleanup', $
                            'mgffepochparser::getProperty', $
                            'mgffepochparser::setProperty']
  self->addTestingRoutine, ['mgffepochparser::init', $
                            'mgffepochparser::get', $
                            'mgffepochparser::is_valid'], $
                           /is_function

  return, 1
end

pro mgffepochparser_ut__define
  compile_opt strictarr

  define = { mgffepochparser_ut, inherits MGutLibTestCase }
end

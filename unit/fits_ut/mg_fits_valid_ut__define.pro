; docformat = 'rst'

function mg_fits_valid_ut::test_invalidfcb
  compile_opt strictarr

  filename = filepath('20150428_223017_kcor_invalid.fts', root=self.fits_data_root)
  fits_open, filename, fcb, /no_abort
  valid = mg_fits_valid(fcb)
  fits_close, fcb

  assert, valid eq 0, '%s marked valid when it is not valid', file_basename(filename)


  return, 1
end


function mg_fits_valid_ut::test_invalidfilename
  compile_opt strictarr

  filename = filepath('20150428_223017_kcor_invalid.fts', root=self.fits_data_root)

  valid = mg_fits_valid(filename)
  assert, valid eq 0, '%s marked valid when it is not valid', file_basename(filename)

  return, 1
end


function mg_fits_valid_ut::test_fcb
  compile_opt strictarr

  filename = filepath('20150428_223017_kcor.fts', root=self.fits_data_root)
  fits_open, filename, fcb
  valid = mg_fits_valid(fcb)
  fits_close, fcb

  assert, valid eq 1, '%s marked not valid when it is valid', file_basename(filename)

  return, 1
end


function mg_fits_valid_ut::test_filename
  compile_opt strictarr

  filename = filepath('20150428_223017_kcor.fts', root=self.fits_data_root)

  valid = mg_fits_valid(filename)
  assert, valid eq 1, '%s marked not valid when it is valid', file_basename(filename)

  return, 1
end


function mg_fits_valid_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mg_fits_valid'], $
                           /is_function

  self.fits_data_root = mg_src_root()

  return, 1
end


pro mg_fits_valid_ut__define
  compile_opt strictarr

  define = { mg_fits_valid_ut, inherits MGutLibTestCase, $
             fits_data_root: '' $
           }
end

; docformat = 'rst'

function mgffncvariable_ut::test_sample
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  f = obj_new('MGffNCFile', filename=file_which('sample.nc'))

  im = f['image']

  assert, array_equal(im.attributes, ['TITLE']), 'incorrect attributes'
  assert, im.groups eq !null, 'incorrect groups'
  assert, im.variables eq !null, 'incorrect variables'

  assert, im['TITLE'] eq 'New York City', 'incorrect attribute value'

  full_data = im[*, *]
  assert, array_equal(size(full_data, /dimensions), [768, 512]), $
          'incorrect dimensions'

  assert, array_equal(full_data[20:100, 30:200], im[20:100, 30:200]), $
          'incorrect subsetting'

  obj_destroy, f

  return, 1
end


function mgffncvariable_ut::test_group
  compile_opt strictarr

  assert, mg_idlversion(require='8.0'), /skip, $
          'test requires IDL 8.0, %s present', !version.release

  f = obj_new('MGffNCFile', filename=file_which('ncgroup.nc'))

  ; TODO: query properties

  obj_destroy, f

  return, 1
end


function mgffncvariable_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mgffncvariable__define', $
                            'mgffncvariable::cleanup', $
                            'mgffncvariable::getProperty', $
                            'mgffncvariable::_computeslab']
  self->addTestingRoutine, ['mgffncvariable::init', $
                            'mgffncvariable::_overloadBracketsRightSide', $
                            'mgffncvariable::_overloadPrint', $
                            'mgffncvariable::dump', $
                            'mgffncvariable::_overloadHelp', $
                            'mgffncvariable::_getAttribute'], $
                           /is_function

  return, 1
end


pro mgffncvariable_ut__define
  compile_opt strictarr

  define = { MGffNCVariable_ut, inherits MGutLibTestCase }
end

; docformat = 'rst'

pro mg_nc_putdata_ut::setup
  compile_opt strictarr

  self->MGutLibTestCase::setup
  self.test_filename = mg_temp_filename('nc_putdata-%s.nc')
end


pro mg_nc_putdata_ut::teardown
  compile_opt strictarr

  if (file_test(self.test_filename)) then file_delete, self.test_filename
  self->MGutLibTestCase::teardown
end


function mg_nc_putdata_ut::test_basic
  compile_opt strictarr

  standard = indgen(10)
  mg_nc_putdata, self.test_filename, 'test', standard
  result = mg_nc_getdata(self.test_filename, 'test')

  result_type = size(result, /type)
  assert, result_type eq 2L, 'incorrect type: %d', result_type

  assert, array_equal(result, standard, /no_typeconv), 'incorrect value'

  return, 1
end


function mg_nc_putdata_ut::test_attribute
  compile_opt strictarr

  var = indgen(10)
  standard = 'Example string attribute'
  mg_nc_putdata, self.test_filename, 'test', var
  mg_nc_putdata, self.test_filename, 'test.example_attribute', standard

  result = mg_nc_getdata(self.test_filename, 'test.example_attribute')

  result_type = size(result, /type)
  assert, result_type eq 7L, 'incorrect type: %d', result_type

  assert, result eq standard, 'incorrect value: %s', result

  return, 1
end


pro mg_nc_putdata_ut__define
  compile_opt strictarr

  define = { mg_nc_putdata_ut, inherits MGutLibTestCase, $
             test_filename: '' $
           }
end

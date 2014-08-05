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
  mg_nc_putdata, self.test_filename, 'test', standard, error=err
  assert, err eq 0, 'MG_NC_PUTDATA: error = %d', err

  result = mg_nc_getdata(self.test_filename, 'test', error=err)
  assert, err eq 0, 'MG_NC_GETDATA: error = %d', err

  result_type = size(result, /type)
  assert, result_type eq 2L, 'incorrect type: %d', result_type

  assert, array_equal(result, standard, /no_typeconv), 'incorrect value'

  return, 1
end


function mg_nc_putdata_ut::test_attribute
  compile_opt strictarr

  var = indgen(10)
  standard = 0.0D
  mg_nc_putdata, self.test_filename, 'test', var, error=err
  assert, err eq 0, 'MG_NC_PUTDATA: error = %d', err
  mg_nc_putdata, self.test_filename, 'test.example_attribute', standard, $
                 error=err
  assert, err eq 0, 'MG_NC_PUTDATA: error = %d', err

  result = mg_nc_getdata(self.test_filename, 'test.example_attribute', $
                         error=err)
  assert, err eq 0, 'MG_NC_GETDATA: error = %d', err

  result_type = size(result, /type)
  assert, result_type eq 5L, 'incorrect type: %d', result_type

  assert, result eq standard, 'incorrect value: %s', result

  return, 1
end


function mg_nc_putdata_ut::test_groupvar
  compile_opt strictarr

  standard = indgen(10)
  mg_nc_putdata, self.test_filename, 'group/example_var', standard, error=err
  assert, err eq 0, 'MG_NC_PUTDATA: error = %d', err

  result = mg_nc_getdata(self.test_filename, 'group/example_var', $
                         error=err)
  assert, err eq 0, 'MG_NC_GETDATA: error = %d', err

  result_type = size(result, /type)
  assert, result_type eq 2L, 'incorrect type: %d', result_type

  assert, array_equal(result, standard), 'incorrect value'

  return, 1
end


function mg_nc_putdata_ut::test_groupattr
  compile_opt strictarr

  standard = 0.0
  mg_nc_putdata, self.test_filename, 'group.example_attribute', standard, $
                 error=err
  assert, err eq 0, 'MG_NC_PUTDATA: error = %d', err

  result = mg_nc_getdata(self.test_filename, 'group.example_attribute', $
                         error=err)
  assert, err eq 0, 'MG_NC_GETDATA: error = %d', err

  result_type = size(result, /type)
  assert, result_type eq 4L, 'incorrect type: %d', result_type

  assert, result eq standard, 'incorrect value: %s', result

  return, 1
end


function mg_nc_putdata_ut::test_string_rootattr
  compile_opt strictarr

  standard = 'meters'
  mg_nc_putdata, self.test_filename, '.example_attribute', standard, $
                 error=err
  assert, err eq 0, 'MG_NC_PUTDATA: error = %d', err

  result = mg_nc_getdata(self.test_filename, '.example_attribute', $
                         error=err)
  assert, err eq 0, 'MG_NC_GETDATA: error = %d', err

  result_type = size(result, /type)
  assert, result_type eq 7L, 'incorrect root attribute type: %d', result_type

  assert, result eq standard, 'incorrect root attribute value: %s', result

  return, 1
end


function mg_nc_putdata_ut::test_string_groupattr
  compile_opt strictarr

  standard = 'meters'
  mg_nc_putdata, self.test_filename, 'group.example_attribute', standard, $
                 error=err
  assert, err eq 0, 'MG_NC_PUTDATA: error = %d', err

  result = mg_nc_getdata(self.test_filename, 'group.example_attribute', $
                         error=err)
  assert, err eq 0, 'MG_NC_GETDATA: error = %d', err

  result_type = size(result, /type)
  assert, result_type eq 7L, 'incorrect group attribute type: %d', result_type

  assert, result eq standard, 'incorrect group attribute value: %s', result

  return, 1
end


function mg_nc_putdata_ut::test_string_varattr
  compile_opt strictarr

  standard = 'meters'

  mg_nc_putdata, self.test_filename, 'var', findgen(10), error=err
  assert, err eq 0, 'MG_NC_PUTDATA: error = %d', err

  mg_nc_putdata, self.test_filename, 'var.example_attribute', standard, $
                 error=err
  assert, err eq 0, 'MG_NC_PUTDATA: error = %d', err

  result = mg_nc_getdata(self.test_filename, 'var.example_attribute', $
                         error=err)
  assert, err eq 0, 'MG_NC_GETDATA: error = %d', err

  result_type = size(result, /type)
  assert, result_type eq 7L, 'incorrect var attribute type: %d', result_type

  assert, result eq standard, 'incorrect var attribute value: %s', result



  return, 1
end


function mg_nc_putdata_ut::test_rootattr
  compile_opt strictarr

  standard = 'Example string attribute'
  mg_nc_putdata, self.test_filename, '.example_attribute', standard, error=err
  assert, err eq 0, 'MG_NC_PUTDATA: error = %d', err

  result = mg_nc_getdata(self.test_filename, '.example_attribute', error=err)
  assert, err eq 0, 'MG_NC_GETDATA: error = %d', err

  result_type = size(result, /type)
  assert, result_type eq 7L, 'incorrect type: %d', result_type

  assert, result eq standard, 'incorrect value: %s', result

  return, 1
end


function mg_nc_putdata_ut::test_rootattr_withslash
  compile_opt strictarr

  standard = 'Example string attribute'
  mg_nc_putdata, self.test_filename, '/.example_attribute', standard, error=err
  assert, err eq 0, 'MG_NC_PUTDATA: error = %d', err

  result = mg_nc_getdata(self.test_filename, '/.example_attribute', error=err)
  assert, err eq 0, 'MG_NC_GETDATA: error = %d', err

  result_type = size(result, /type)
  assert, result_type eq 7L, 'incorrect type: %d', result_type

  assert, result eq standard, 'incorrect value: %s', result

  return, 1
end


function mg_nc_putdata_ut::test_2dvar
  compile_opt strictarr

  standard = dindgen(2, 10)
  mg_nc_putdata, self.test_filename, 'example_2dvar', standard, $
                 dim_names=['nv', 'lat'], error=err
  assert, err eq 0, 'MG_NC_PUTDATA: error = %d', err

  result = mg_nc_getdata(self.test_filename, 'example_2dvar', error=err)
  assert, err eq 0, 'MG_NC_GETDATA: error = %d', err

  result_type = size(result, /type)
  assert, result_type eq 5L, 'incorrect type: %d', result_type

  assert, array_equal(result, standard), 'incorrect value'

  return, 1
end


pro mg_nc_putdata_ut__define
  compile_opt strictarr

  define = { mg_nc_putdata_ut, inherits MGutLibTestCase, $
             test_filename: '' $
           }
end

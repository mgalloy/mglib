; docformat = 'rst'

pro mg_nc_decompose_ut::setup
  compile_opt strictarr

  self->MGutLibTestCase::setup
  self.test_filename = mg_temp_filename('nc_decompose-%s.nc')
end


pro mg_nc_decompose_ut::teardown
  compile_opt strictarr

  if (file_test(self.test_filename)) then file_delete, self.test_filename
  self->MGutLibTestCase::teardown
end


function mg_nc_decompose_ut::test_var
  compile_opt strictarr

  filename = file_which('ncgroup.nc')
  file_id = ncdf_open(filename)

  desc = '/Submarine/Diesel_Electric/Sub Depth'
  type = mg_nc_decompose(file_id, desc, $
                         element_name=elname, parent_type=parent_type)

  assert, type eq 2L, 'incorrect type: %d', type
  assert, parent_type eq 3L, 'incorrect parent type: %d', parent_type
  assert, elname eq 'Sub Depth', 'incorrect element name: %s', elname

  ncdf_close, file_id

  return, 1
end


function mg_nc_decompose_ut::test_attr
  compile_opt strictarr

  filename = file_which('ncgroup.nc')
  file_id = ncdf_open(filename)

  desc = '/Submarine/Diesel_Electric/Sub Depth.attr'
  type = mg_nc_decompose(file_id, desc, $
                         element_name=elname, parent_type=parent_type)

  assert, type eq 1L, 'incorrect type: %d', type
  assert, parent_type eq 2L, 'incorrect parent type: %d', parent_type
  assert, elname eq 'attr', 'incorrect element name: %s', elname

  desc = '/Submarine/Diesel_Electric.attr'
  type = mg_nc_decompose(file_id, desc, $
                         element_name=elname, parent_type=parent_type)

  assert, type eq 1L, 'incorrect type: %d', type
  assert, parent_type eq 3L, 'incorrect parent type: %d', parent_type
  assert, elname eq 'attr', 'incorrect element name: %s', elname

  ncdf_close, file_id

  return, 1
end


function mg_nc_decompose_ut::test_write_attr
  compile_opt strictarr

  file_id = ncdf_create(self.test_filename, /netcdf4_format)

  desc = '/group1/group2/group3.attr'
  type = mg_nc_decompose(file_id, desc, $
                         element_name=elname, parent_type=parent_type, $
                         /write)

  assert, type eq 1L, 'incorrect type: %d', type
  assert, parent_type eq 3L, 'incorrect parent type: %d', parent_type
  assert, elname eq 'attr', 'incorrect element name: %s', elname

  ncdf_close, file_id

  standard = indgen(10)
  mg_nc_putdata, self.test_filename, '/group1/group2/group3/var', standard, $
                 error=err
  assert, err eq 0, 'MG_NC_PUTDATA: error = %d', err

  result = mg_nc_getdata(self.test_filename, '/group1/group2/group3/var', $
                         error=err)
  assert, err eq 0, 'MG_NC_GETDATA: error = %d', err

  assert, array_equal(standard, result, /no_typeconv), 'incorrect result'

  return, 1
end


function mg_nc_decompose_ut::test_write_var
  compile_opt strictarr

  return, 1
end


function mg_nc_decompose_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mg_nc_decompose', $
                            'mg_nc_varid'], $
                           /is_function

  return, 1
end


pro mg_nc_decompose_ut__define
  compile_opt strictarr

  define = { mg_nc_decompose_ut, inherits MGutLibTestCase, $
             test_filename: '' $
           }
end

function mg_h5_getdata_ut::test_attribute
  compile_opt strictarr

  f = file_which('hdf5_test.h5')

  eskimo_class = mg_h5_getdata(f, '/images/Eskimo.CLASS')
  assert, eskimo_class eq 'IMAGE', 'incorrect value for Eskimo.CLASS, %s', $
          eskimo_class

  return, 1
end


function mg_h5_getdata_ut::test_variable
  compile_opt strictarr

  f = file_which('hdf5_test.h5')

  result = mg_h5_getdata(f, '/arrays/3D int array')
  assert, size(result, /n_dimensions) eq 3, $
          'incorrect number of dimensions for result'
  assert, array_equal(size(result, /dimensions), [10, 50, 100]), $
          'incorrect dimension sizes for result'
  assert, size(result, /type) eq 3, $
          'incorrect type for result'

  restore, filename=filepath('h5_parse_result.sav', root=mg_src_root())
  assert, array_equal(h5_parse_result, result), $
          'incorrect result'

  return, 1
end


function mg_h5_getdata_ut::test_variableslice
  compile_opt strictarr

  f = file_which('hdf5_test.h5')

  full_result = mg_h5_getdata(f, '/arrays/3D int array')
  slice1 = mg_h5_getdata(f, '/arrays/3D int array', $
                         bounds=[[3, 3, 1], [5, 49, 2], [0, 49, 3]])
  assert, array_equal(slice1, full_result[3, 5:*:2, 0:49:3]), $
          'incorrect value for slice using BOUNDS keyword'

  slice2 = mg_h5_getdata(f, '/arrays/3D int array[3, 5:*:2, 0:49:3]')
  assert, array_equal(slice2, full_result[3, 5:*:2, 0:49:3]), $
          'incorrect value for slice using string notation'

  return, 1
end


pro mg_h5_getdata_ut__define
  compile_opt strictarr

  define = { mg_h5_getdata_ut, inherits MGutLibTestCase }
end

; docformat = 'rst'

pro mg_grib_getdata_ut::setup
  compile_opt strictarr
end


pro mg_grib_getdata_ut::teardown
  compile_opt strictarr
end


function mg_grib_getdata_ut::test_scalars
  compile_opt strictarr

  filename = filepath('atl.grb2', root='.')

  keys = ['Ni', 'radius', 'masterDir']
  standards = hash()
  standards['Ni'] = 391
  standards['radius'] = 6371200.0
  standards['masterDir'] = 'grib2/tables/[tablesVersion]'
  for r = 1, grib_count(filename) do begin
    foreach key, keys do begin
      result = mg_grib_getdata(filename, key, record=r)
      assert, result eq standards[key], 'incorrect value for key: %s', key
    endforeach
  endfor

  return, 1
end


function mg_grib_getdata_ut::test_array
  compile_opt strictarr

  filename = filepath('atl.grb2', root='.')
  key = 'values'

  file = grib_open(filename)

  for r = 1, grib_count(filename) do begin
    result = mg_grib_getdata(filename, key, record=r)

    ghandle = grib_new_from_file(file)
    standard = grib_get_array(ghandle, key)

    assert, array_equal(result, standard), $
            'incorrect value for key: %s at record: %d', key, r
    grib_release, ghandle
  endfor

  grib_close, file

  return, 1
end


pro mg_grib_getdata_ut__define
  compile_opt strictarr

  define = { mg_grib_getdata_ut, inherits MGutLibTestCase }
end

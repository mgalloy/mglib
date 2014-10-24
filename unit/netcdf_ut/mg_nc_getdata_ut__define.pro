; docformat = 'rst'

function mg_nc_getdata_ut::test_sample
  compile_opt strictarr

  filename = file_which('sample.nc')

  title = mg_nc_getdata(filename, '.TITLE', error=err)
  assert, err eq 0, 'MG_NC_GETDATA error = %d', err
  result_type = size(title, /type)
  assert, result_type eq 7, 'incorrect type for title: %d', result_type
  assert, title eq 'Incredibly Important Data', 'incorrect title'

  galaxy = mg_nc_getdata(filename, '.GALAXY', error=err)
  assert, err eq 0, 'MG_NC_GETDATA error = %d', err
  result_type = size(galaxy, /type)
  assert, result_type eq 7, 'incorrect type for galaxy: %d', result_type
  assert, galaxy eq 'Milky Way', 'incorrect galaxy'

  planet = mg_nc_getdata(filename, '.PLANET', error=err)
  assert, err eq 0, 'MG_NC_GETDATA error = %d', err
  result_type = size(planet, /type)
  assert, result_type eq 7, 'incorrect type for planet: %d', result_type
  assert, planet eq 'Earth', 'incorrect planet'

  im_title = mg_nc_getdata(filename, 'image.TITLE', error=err)
  assert, err eq 0, 'MG_NC_GETDATA error = %d', err
  result_type = size(im_title, /type)
  assert, result_type eq 7, 'incorrect type for image title: %d', result_type
  assert, im_title eq 'New York City', 'incorrect image title'

  im = mg_nc_getdata(filename, 'image', error=err)
  assert, err eq 0, 'MG_NC_GETDATA error = %d', err

  dims = size(im, /dimensions)
  assert, array_equal(dims, [768, 512]), $
          'incorrect dimensions: [%s]', strjoin(strtrim(dims, 2), ', ')
  return, 1
end


function mg_nc_getdata_ut::test_group
  compile_opt strictarr

  filename = file_which('ncgroup.nc')

  varname = '/Submarine/Diesel_Electric/Sub Depth'
  diesel = mg_nc_getdata(filename, varname, error=err)
  assert, err eq 0, 'MG_NC_GETDATA: error = %d', err
  result_type = size(diesel, /type)
  result_dims = size(diesel, /dimensions)
  assert, result_type eq 2L, 'incorrect diesel type: %d', result_type
  assert, array_equal(result_dims, [2]), $
          'incorrect dimensions for %s: [%s]', $
          varname, strjoin(strtrim(result_dims, 2), ', ')

  varname = '/Submarine/Nuclear/Attack/Sub Depth'
  attack = mg_nc_getdata(filename, varname, error=err)
  assert, err eq 0, 'MG_NC_GETDATA: error = %d', err
  result_type = size(attack, /type)
  result_dims = size(attack, /dimensions)
  assert, result_type eq 2L, 'incorrect diesel type: %d', result_type
  assert, array_equal(result_dims, [4]), $
          'incorrect dimensions for %s: [%s]', $
          varname, $
          strjoin(strtrim(result_dims, 2), ', ')

  varname = '/Submarine/Nuclear/Missile/Sub Depth'
  missile = mg_nc_getdata(filename, varname, error=err)
  assert, err eq 0, 'MG_NC_GETDATA: error = %d', err
  result_type = size(missile, /type)
  result_dims = size(missile, /dimensions)
  assert, result_type eq 2L, 'incorrect diesel type: %d', result_type
  assert, array_equal(result_dims, [3]), $
          'incorrect dimensions for %s: [%s]', $
          varname, $
          strjoin(strtrim(result_dims, 2), ', ')

  return, 1
end


function mg_nc_getdata_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_nc_getdata_computeslab'
  self->addTestingRoutine, ['mg_nc_getdata', $
                            'mg_nc_getdata_getattribute', $
                            'mg_nc_getdata_getattributedata', $
                            'mg_nc_getdata_getvariable', $
                            'mg_nc_getdata_convertbounds', $
                            'mg_nc_getdata_convertbounds_1d'], $
                           /is_function

  return, 1
end


pro mg_nc_getdata_ut__define
  compile_opt strictarr

  define = { mg_nc_getdata_ut, inherits MGutLibTestCase }
end

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

  diesel = mg_nc_getdata(filename, 'Submarine/Diesel_Electric/Sub Depth', error=err)
  assert, err eq 0, 'MG_NC_GETDATA error = %d', err
  result_type = size(diesel, /type)
  result_dims = size(diesel, /dimensions)
  assert, result_type eq 2L, 'incorrect diesel type: %d', result_type
  assert, array_equal(result_dims, [2]), $
          'incorrect dimensions: [%s]', strjoin(strtrim(result_dims, 2), ', ')

  attack = mg_nc_getdata(filename, 'Submarine/Nuclear/Attack/Sub Depth', error=err)
  assert, err eq 0, 'MG_NC_GETDATA error = %d', err
  result_type = size(attack, /type)
  result_dims = size(attack, /dimensions)
  assert, result_type eq 2L, 'incorrect diesel type: %d', result_type
  assert, array_equal(result_dims, [2]), $
          'incorrect dimensions: [%s]', strjoin(strtrim(result_dims, 2), ', ')

  missile = mg_nc_getdata(filename, 'Submarine/Nuclear/Missile/Sub Depth', error=err)
  assert, err eq 0, 'MG_NC_GETDATA error = %d', err
  result_type = size(missile, /type)
  result_dims = size(missile, /dimensions)
  assert, result_type eq 2L, 'incorrect diesel type: %d', result_type
  assert, array_equal(result_dims, [2]), $
          'incorrect dimensions: [%s]', strjoin(strtrim(result_dims, 2), ', ')

  return, 1
end


pro mg_nc_getdata_ut__define
  compile_opt strictarr

  define = { mg_nc_getdata_ut, inherits MGutLibTestCase }
end

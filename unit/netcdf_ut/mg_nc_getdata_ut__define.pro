; docformat = 'rst'

function mg_nc_getdata_ut::test_sample
  compile_opt strictarr

  filename = file_which('sample.nc')

  title = mg_nc_getdata(filename, '.title')
  result_type = size(title, /type)
  assert, result_type eq 7, 'incorrect type for title: %d', result_type
  assert, title eq 'Incredibly Important Data', 'incorrect title'

  galaxy = mg_nc_getdata(filename, '.title')
  result_type = size(galaxy, /type)
  assert, result_type eq 7, 'incorrect type for galaxy: %d', result_type
  assert, galaxy eq 'Milky Way', 'incorrect galaxy'

  planet = mg_nc_getdata(filename, '.title')
  result_type = size(planet, /type)
  assert, result_type eq 7, 'incorrect type for planet: %d', result_type
  assert, planet eq 'Earth', 'incorrect planet'

  im_title = mg_nc_getdata(filename, 'image.title')
  result_type = size(im_title, /type)
  assert, result_type eq 7, 'incorrect type for image title: %d', result_type
  assert, im_title eq 'New York City', 'incorrect image title'

  im = mg_nc_getdata(filename, 'image')

  dims = size(im, /dimensions)
  assert, array_equal(dims, [512, 768]), $
          'incorrect dimensions: [%s]', strjoin(strtrim(dims, 2), ', ')
  return, 1
end


function mg_nc_getdata_ut::test_group
  compile_opt strictarr

  filename = file_which('ncgroup.nc')

  ; TODO: query attributes, groups, variables

  return, 1
end


pro mg_nc_getdata_ut__define
  compile_opt strictarr

  define = { mg_nc_getdata_ut, inherits MGutLibTestCase }
end

; docformat = 'rst'

function mg_nc_getdata_ut::test_sample
  compile_opt strictarr

  filename = file_which('sample.nc')

  ; TODO: query attributes, variables

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

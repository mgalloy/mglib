; docformat = 'rst'

function mgffncfile_ut::test_sample
  compile_opt strictarr
  
  f = obj_new('MGffNCFile', filename=file_which('sample.nc'))
  
  assert, array_equal(f.attributes, ['TITLE', 'GALAXY', 'PLANET']), $
          'incorrect attributes'
  assert, f.groups eq !null, 'incorrect groups'
  assert, array_equal(f.variables, ['image']), 'incorrect variables'
  
  obj_destroy, f
  
  return, 1
end


function mgffncfile_ut::test_group
  compile_opt strictarr
  
  f = obj_new('MGffNCFile', filename=file_which('ncgroup.nc'))
  
  assert, array_equal(f.groups, ['Submarine']), 'incorrect groups'
  assert, f.attributes eq !null, 'incorrect attributes'
  assert, f.variables eq !null, 'incorrect variables'
  
  obj_destroy, f
  
  return, 1
end


pro mgffncfile_ut__define
  compile_opt strictarr
  
  define = { MGffNCFile_ut, inherits MGutLibTestCase }
end

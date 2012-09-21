; docformat = 'rst'

function mgffncvariable_ut::test_sample
  compile_opt strictarr
  
  f = obj_new('MGffNCFile', filename=file_which('sample.nc'))
  
  im = f['image']
  
  assert, array_equal(im.attributes, ['TITLE']), 'incorrect attributes'
  assert, im.groups eq !null, 'incorrect groups'
  assert, im.variables eq !null, 'incorrect variables'
  
  assert, im['TITLE'] eq 'New York City', 'incorrect attribute value'
  
  full_data = im[*, *]
  assert, array_equal(size(full_data, /dimensions), [768, 512]), $
          'incorrect dimensions'
          
  assert, array_equal(full_data[20:100, 30:200], im[20:100, 30:200]), $
          'incorrect subsetting'
          
  obj_destroy, f
  
  return, 1
end


function mgffncvariable_ut::test_group
  compile_opt strictarr
  
  f = obj_new('MGffNCFile', filename=file_which('ncgroup.nc'))
  
  ; TODO: query properties
  
  obj_destroy, f
  
  return, 1
end


pro mgffncvariable_ut__define
  compile_opt strictarr
  
  define = { MGffNCVariable_ut, inherits MGutLibTestCase }
end

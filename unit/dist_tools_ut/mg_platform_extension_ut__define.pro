; docformat = 'rst'


function mg_platform_extension_ut::test_basic
  compile_opt strictarr

  ext = mg_platform_extension()
  
  assert, file_test(filepath('bin.' + ext, subdir='bin')), $
          'platform extension not found'
          
  return, 1
end


;+
; Define member variables.
;-
pro mg_platform_extension_ut__define
	compile_opt strictarr
	
	define = { mg_platform_extension_ut, inherits MGutLibTestCase }
end
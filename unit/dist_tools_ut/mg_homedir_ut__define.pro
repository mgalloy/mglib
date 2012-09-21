; docformat = 'rst'


function mg_homedir_ut::test_type
  compile_opt strictarr
  
  homedir = mg_homedir()
  
  assert, size(homedir, /type) eq 7L, 'incorrect type'
  
  return, 1
end


;+
; Define instance variables.
;-
pro mg_homedir_ut__define
  compile_opt strictarr
  
  define = { mg_homedir_ut, inherits MGutTestCase }
end

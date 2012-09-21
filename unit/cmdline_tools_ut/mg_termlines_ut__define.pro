; docformat = 'rst'


function mg_termlines_ut::test_positive
  compile_opt strictarr
  
  lines = mg_termlines()
  
  assert, lines gt 0L, 'negative number of lines in the terminal window'
  
  return, 1
end


;+
; Define instance variables.
;-
pro mg_termlines_ut__define
  compile_opt strictarr
  
  define = { mg_termlines_ut, inherits MGutTestCase }
end

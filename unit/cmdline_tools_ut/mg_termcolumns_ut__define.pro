; docformat = 'rst'


function mg_termcolumns_ut::test_positive
  compile_opt strictarr
  
  columns = mg_termcolumns()
  
  assert, columns gt 0L, 'negative number of lines in the terminal window'
  
  return, 1
end


;+
; Define instance variables.
;-
pro mg_termcolumns_ut__define
  compile_opt strictarr
  
  define = { mg_termcolumns_ut, inherits MGutTestCase }
end

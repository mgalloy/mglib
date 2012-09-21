; docformat = 'rst'


function mg_loginname_ut::test_type
  compile_opt strictarr
  
  loginname = mg_loginname()
  
  assert, size(loginname, /type) eq 7L, 'incorrect type'
  
  return, 1
end


function mg_loginname_ut::test_unixSystems
  compile_opt strictarr
  
  loginname = mg_loginname()
  
  if (!version.os_family eq 'unix') then begin
    spawn, 'whoami', unix_loginname
    assert, loginname eq unix_loginname[0], 'loginname does not match whoami'
  endif
  
  return, 1
end

;+
; Define instance variables.
;-
pro mg_loginname_ut__define
  compile_opt strictarr
  
  define = { mg_loginname_ut, inherits MGutTestCase }
end

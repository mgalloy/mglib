; docformat = 'rst'


function mg_pid_ut::test_type
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_DIST_TOOLS DLM not found', /skip

  pid = mg_pid()

  assert, size(pid, /type) eq 7L, 'incorrect type'

  return, 1
end


;+
; Define instance variables.
;-
pro mg_pid_ut__define
  compile_opt strictarr

  define = { mg_pid_ut, inherits MGutLibTestCase }
end

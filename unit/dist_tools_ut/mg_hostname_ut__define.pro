; docformat = 'rst'


function mg_hostname_ut::test_type
  compile_opt strictarr

  assert, self->have_dlm('mg_analysis'), 'MG_DIST_TOOLS DLM not found', /skip

  hostname = mg_hostname()

  assert, size(hostname, /type) eq 7L, 'incorrect type'

  return, 1
end


;+
; Define instance variables.
;-
pro mg_hostname_ut__define
  compile_opt strictarr

  define = { mg_hostname_ut, inherits MGutLibTestCase }
end

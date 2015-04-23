; docformat = 'rst'

pro mg_join_demo
  compile_opt strictarr

  ; do something
end


; main-level example program

p = mg_process()
p->execute, '', /nowait
; do something
p->join

mg_log, ''

end

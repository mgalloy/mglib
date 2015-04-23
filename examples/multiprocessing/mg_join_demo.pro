; docformat = 'rst'

;+
; Example task which takes about 10.0 seconds to complete.
;-
pro mg_join_demo
  compile_opt strictarr

  t0 = systime(/seconds)
  mg_log, 'subprocess starting'
  wait, 2.5
  mg_log, '2.5 seconds into subprocess task'
  wait, 7.5
  t1 = systime(/seconds)
  mg_log, 'subprocess done: %0.1f sec elapsed', t1 - t0
end


; main-level example program

p = mg_process(name='demo process', output='')

t0 = systime(/seconds)
p->execute, 'mg_join_demo', /nowait

main_t0 = systime(/seconds)
mg_log, 'main process starting'
wait, 5.0
main_t1 = systime(/seconds)
mg_log, 'main process done: %0.1f sec elapsed', main_t1 - main_t0

p->join
t1 = systime(/seconds)

mg_log, '%0.1f sec elapsed', t1 - t0

end

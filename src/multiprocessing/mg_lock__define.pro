; docformat = 'rst'

;+
; Lock for a shared resource.
;-


function mg_lock::acquire, no_block=no_block
  compile_opt strictarr

  status = sem_lock(self.name)
  if (keyword_set(no_block)) then return, status

  while (status ne 1) do begin
    wait, self.polling_cycle
    status = sem_lock(self.name)
  endwhile

  return, 1B
end


pro mg_lock::release
  compile_opt strictarr
  sem_release, self.name
end


pro mg_lock::cleanup
  compile_opt strictarr

  sem_delete, self.name
end


function mg_lock::init, name=name, polling_cycle=polling_cycle
  compile_opt strictarr
  on_error, 2

  if (n_elements(name) eq 0L) then message, 'NAME required'

  self.name = name
  self.polling_cycle = n_elements(polling_cycle) eq 0L ? 0.5 : polling_cycle

  return, sem_create(self.name)
end


pro mg_lock__define
  compile_opt strictarr

  define = { mg_lock, inherits IDL_Object, $
             name: '', $
             polling_cycle: 0.0 $
           }
end


; main-level example program

end

; docformat = 'rst'

function mg_semaphore::acquire
  compile_opt strictarr

  acquired = self.lock->acquire()
  while ((*self.counter)[0] lt 1L) do begin
    self.lock->release
    wait, self.polling_cycle
    acquired = self.lock->acquire()
  endwhile
  --(*self.counter)[0]
  self.lock->release

  return, 1
end


pro mg_semaphore::release
  compile_opt strictarr

  acquired = self.lock->acquire()

  if (self.max_value lt 0L || ((*self.counter)[0] lt self.max_value)) then begin
    ++(*self.counter)[0]
  endif

  self.lock->release
end


pro mg_semaphore::getProperty, name=name, value=value, max_value=max_value
  compile_opt strictarr

  if (arg_present(name)) then name = self.name
  if (arg_present(polling_cycle)) then polling_cycle = self.polling_cycle
  if (arg_present(max_value)) then max_value = self.max_value

  if (arg_present(value)) then begin
    acquired = self.lock->acquire()
    value = (*self.counter)[0]
    self.lock->release
  endif
end


pro mg_semaphore::setProperty, polling_cycle=polling_cycle, max_value=max_value
  compile_opt strictarr

  if (n_elements(polling_cycle) gt 0L) then self.polling_cycle = polling_cycle
  if (n_elements(max_value) gt 0L) then self.max_value = max_value
end


pro mg_semaphore::cleanup
  compile_opt strictarr

  obj_destroy, self.lock
end


function mg_semaphore::init, counter, name=name, polling_cycle=polling_cycle, $
                             max_value=max_value
  compile_opt strictarr
  on_error, 2

  if (n_elements(name) eq 0L) then message, 'NAME required'

  self.name = name
  self.polling_cycle = n_elements(polling_cycle) eq 0L ? 0.5 : polling_cycle
  self.max_value = n_elements(max_value) eq 0L ? -1L : max_value

  shmmap, self.name, /long, 1
  z = shmvar(self.name)
  self.counter = ptr_new(z, /no_copy)

  self.lock = mg_lock(name=self.name, polling_cycle=polling_cycle)
  if (~obj_valid(self.lock)) then return, 0

  if (n_elements(counter) gt 0L) then begin
    acquired = self.lock->acquire()
    (*self.counter)[0] = counter
    self.lock->release
  endif

  return, 1
end


pro mg_semaphore__define
  compile_opt strictarr

  define = { mg_semaphore, inherits IDL_Object, $
             name: '', $
             counter: ptr_new(), $
             max_value: 0L, $
             polling_cycle: 0.0, $
             lock: obj_new() $
           }
end


; main-level example program

end

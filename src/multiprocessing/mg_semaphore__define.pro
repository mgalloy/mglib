; docformat = 'rst'

;+
; A semaphore is a counter representing some shared and limited resource. For
; example, the number of computational cores or network connections are
; resources that can be shared by multiple processes, but degrade if over
; subscribed.
;
; :Properties:
;   name : type=string
;     name of the semaphore; other processes must use the same name in order
;     to share the count
;   value : type=long
;     value of the counter
;   max_value : type=long
;     maximum allowed value of the counter; releases beyond the maximum value
;     will have no effect
;   polling_cycle : type=float
;     time between polling events, in seconds
;-


;= API

;+
; Acquire a resource limited by the semaphore. Acquiring decrements the
; counter.
;
; :Keywords:
;   acquired : out, optional, type=boolean
;     set to a named variable to retrieve whether the semaphore was acquired;
;     semaphores are always acquired (but may block briefly before returning)
;-
pro mg_semaphore::acquire, acquired=acquired
  compile_opt strictarr

  acquired = self.lock->acquire()
  while ((*self.counter)[0] lt 1L) do begin
    self.lock->release
    wait, self.polling_cycle
    acquired = self.lock->acquire()
  endwhile
  --(*self.counter)[0]
  self.lock->release
end


;+
; Release a resource limited by the semaphore. Releasing increments the
; counter.
;-
pro mg_semaphore::release
  compile_opt strictarr

  acquired = self.lock->acquire()

  if (self.max_value lt 0L || ((*self.counter)[0] lt self.max_value)) then begin
    ++(*self.counter)[0]
  endif

  self.lock->release
end


;= overloaded operators

;+
; Get output for use with `PRINT`.
;
; :Returns:
;   string
;-
function mg_semaphore::_overloadPrint
  compile_opt strictarr

  return, string(self.name, (*self.counter)[0], self.max_value, $
                 format='(%"%s [%d/%d]")')
end


;+
; Overload routine used by `HELP`.
;
; :Returns:
;   string
;
; :Params:
;   varname : in, required, type=string
;     name of variable to provide `HELP` for
;-
function mg_semaphore::_overloadHelp, varname
  compile_opt strictarr

  type = 'MG_SEMAPHORE'
  specs = string(self.name, (*self.counter)[0], self.max_value, $
                 format='(%"<NAME=%s  COUNTER=%d  MAX_VALUE=%d>")')

  return, string(varname, type, specs, format='(%"%-16s %-13s = %s")')
end


;= property access

;+
; Get properties.
;-
pro mg_semaphore::getProperty, name=name, value=value, max_value=max_value, $
                               polling_cycle=polling_cycle
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


;+
; Set properties.
;-
pro mg_semaphore::setProperty, polling_cycle=polling_cycle, max_value=max_value
  compile_opt strictarr

  if (n_elements(polling_cycle) gt 0L) then self.polling_cycle = polling_cycle
  if (n_elements(max_value) gt 0L) then self.max_value = max_value
end


;= lifecycle methods

;+
; Free the resources of the semaphore object. When all the semaphore objects
; are freed, the semaphore itself will be freed.
;-
pro mg_semaphore::cleanup
  compile_opt strictarr

  obj_destroy, self.lock
end


;+
; Create a semaphore object.
;
; :Returns:
;   1 for success, 0 for failure
;
; :Params:
;   counter : in, optional, type=long
;     starting value for counter
;
; :Keywords:
;   name : in, required, type=string
;     name to use for the semaphore; the same name must be used in other
;     processes to refer to the same semaphore
;   polling_cycle : in, optional, type=float, default=0.5
;     time to wait between polling events, in seconds
;   max_value : in, optional, type=long
;     if set, `MAX_VALUE` provides a maximum value for the counter; `::release`
;     calls beyond the `MAX_VALUE` do not increase the counter
;-
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


;+
; Define `MG_Semaphore` class.
;-
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

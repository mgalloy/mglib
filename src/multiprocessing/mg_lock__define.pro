; docformat = 'rst'

;+
; A lock is a binary value representing the availabity of some shared and
; limited resource.
;
; :Properties:
;   name : type=string
;     name of the lock; other processes must use the same name in order
;     to share the lock
;   polling_cycle : type=float
;     time between polling events, in seconds
;   acquired : type=boolean
;     specifies whether the lock object has acquired the lock
;-


;= API

;+
; Acquire a resource limited by the lock.
;
; :Keywords:
;   no_block : in, optional, type=boolean
;     set to not block, by default will block until lock is acquires; if
;     `NO_BLOCK` is set, will return immediately, check `ACQUIRED` keyword
;     value to determine if the lock was actually acquired
;   acquired : out, optional, type=boolean
;     set to a named variable to retrieve whether the lock was acquired; if
;     `NO_BLOCK` is not set, the lock is always acquired though `acquire` may
;     block for some time to acquire it; if `NO_BLOCK` is set, `acquire` will
;     always return immediately, but the lock may or may not have been aquired
;-
pro mg_lock::acquire, no_block=no_block, acquired=acquired
  compile_opt strictarr

  self.acquired = sem_lock(self.name)
  acquired = self.acquired
  if (keyword_set(no_block)) then return

  while (acquired ne 1) do begin
    wait, self.polling_cycle
    self.acquired = sem_lock(self.name)
  endwhile

  acquired = self.acquired
end


;+
; Release the lock.
;-
pro mg_lock::release
  compile_opt strictarr

  self.acquired = 0B
  sem_release, self.name
end


;= overloaded operators

;+
; Get output for use with `PRINT`.
;
; :Returns:
;   string
;-
function mg_lock::_overloadPrint
  compile_opt strictarr

  return, string(self.name, $
                 self.acquired ? 'acquired' : 'not acquired', $
                 format='(%"%s [%s]")')
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
function mg_lock::_overloadHelp, varname
  compile_opt strictarr

  type = 'MG_LOCK'
  specs = string(self.name, format='(%"<NAME=%s>")')

  return, string(varname, type, specs, format='(%"%-16s %-13s = %s")')
end


;= property access

;+
; Get properties.
;-
pro mg_lock::getProperty, name=name, polling_cycle=polling_cycle, $
                          acquired=acquired
  compile_opt strictarr

  if (arg_present(name)) then name = self.name
  if (arg_present(polling_cycle)) then polling_cycle = self.polling_cycle
  if (arg_present(acquired)) then acquired = self.acquired
end


;+
; Set properties.
;-
pro mg_lock::setProperty, polling_cycle=polling_cycle
  compile_opt strictarr

  if (n_elements(polling_cycle) gt 0L) then self.polling_cycle = polling_cycle
end


;= lifecycle methods

;+
; Free resources.
;-
pro mg_lock::cleanup
  compile_opt strictarr

  sem_delete, self.name
end


;+
; Create lock object.
;
; :Returns:
;   1 for success, 0 for failure
;
; :Keywords:
;   name : in, required, type=string
;     name of the lock; other processes must use the same name in order
;     to share the lock
;   polling_cycle : in, optional, type=float, default=0.5
;     time between polling events, in seconds
;-
function mg_lock::init, name=name, polling_cycle=polling_cycle
  compile_opt strictarr
  on_error, 2

  if (n_elements(name) eq 0L) then message, 'NAME required'

  self.name = name
  self.polling_cycle = n_elements(polling_cycle) eq 0L ? 0.5 : polling_cycle

  return, sem_create(self.name)
end


;+
; Define lock class.
;-
pro mg_lock__define
  compile_opt strictarr

  define = { mg_lock, inherits IDL_Object, $
             name: '', $
             acquired: 0B, $
             polling_cycle: 0.0 $
           }
end


; main-level example program

end

; docformat = 'rst'

;+
; Wrapper class for `IDL_IDLBridge` which provides some hooks for the other
; multiprocessing classes such as `MG_Pool` and `MG_Queue`.
;
; :Properties:
;   name : type=string
;     name for the process
;   cb_object : type=object
;     object whose method specified by `cb_method` should be called on task
;     completion
;   cb_method : type=string
;     method of `cb_object` that should be called on task completion
;   polling_cycle : type=float
;     time, in seconds, to wait before checking again to see if work is
;     completed, default is 0.5 seconds
;   _extra : type=keywords
;     keywords to `IDL_IDLBridge`
;-


;= helper routines/methods

;+
; Default callback routine for `CALLBACK` property of `MG_Process`. A callback
; must be set to make sure `MG_Process::onCallback` is called, but this default
; routine does not do anything.
;
; :Private:
;
; :Params:
;   status : in, required, type=integer
;     status -- 2 for completion, 3 for error, 4 for aborted
;   error : in, required, type=string
;     error message if status is 3
;   process : in, required, type=object
;     `MG_Process` object
;   userdata : in, required, type=any
;     value of `USERDATA` property of `MG_Process`
;-
pro mg_process_callback, status, error, process, userdata
  compile_opt strictarr

  ; pass
end


;+
; Method which calls callback routine and/or method.
;
; :Private:
;
; :Params:
;   status : in, required, type=integer
;     status -- 2 for completion, 3 for error, 4 for aborted
;   error : in, required, type=string
;     error message if status is 3
;-
pro mg_process::onCallback, status, error
  compile_opt strictarr

  ; call CALLBACK routine, if set
  self->IDL_IDLBridge::onCallback, status, error

  ; call cb_object::cb_method if set
  if (obj_valid(self.cb_object) && self.cb_method ne '') then begin
    call_method, self.cb_method, self.cb_object, self, status, error
  endif
end


;= API

;+
; Execute a statement inside the process.
;
; :Keywords:
;   nowait : in, optional, type=boolean
;     set for asynchronous execution
;-
pro mg_process::execute, cmd, nowait=nowait
  compile_opt strictarr

  self->IDL_IDLBridge::execute, cmd, nowait=nowait
end


;+
; Wait for a process to complete; check `status` and `error` to
; determine if it completed (status 2), error (status 3), or was
; aborted (status 4).
;
; :Keywords:
;   status : out, optional, type=long
;     set to a named variable to retrieve the status of the process on
;     completion
;   error : out, optional, type=string
;     set to a named variable to retrieve an error message if
;     `status` is 3 or 4, it will be an empty string if `status` is 2
;-
pro mg_process::join, status=status, error=error
  compile_opt strictarr
  
  status = self->status(error=error)
  while (status eq 1) do begin
    wait, self.polling_cycle
    status = self->status(error=error)
  endwhile
end


;+
; Get a variable from the process.
;
; :Returns:
;   any variable
;
; :Params:
;   varname : in, required, type=string
;     name of the variable to retrieve
;
; :Keywords:
;   error : out, optional, type=long
;     set to a named variable to retrieve the error status of getting the
;     variable, will be 0 if no errors
;-
function mg_process::getvar, varname, error=error
  compile_opt strictarr

   catch, error
   if (error ne 0L) then begin
     catch, /cancel
     return, !null
   endif

   var = self->IDL_IDLBridge::getvar(varname)
   return, var
end


;= overloaded operators

;+
; Provides convenient output for `HELP` on `NAME` process object.
;
; :Examples:
;   Use `HELP` to show output::
;
;     IDL> p = mg_process(name='background')
;     IDL> help, p
;     P               MG_PROCESS  <NAME=background>
;
; :Params:
;   name : in, required, type=string
;     name of variable
;-
function mg_process::_overloadHelp, name
  compile_opt strictarr

  return, string(name, obj_class(self), self.name, $
                 format='(%"%-16s%s  <NAME=%s>")')
end


;= property access

;+
; Set properties.
;-
pro mg_process::setProperty, name=name, $
                             cb_object=callback_object, $
                             cb_method=callback_method, $
                             polling_cycle=polling_cycle, $
                             _extra=e
  compile_opt strictarr

  if (n_elements(name) gt 0L) then self.name = name
  if (n_elements(callback_object) gt 0L) then begin
    self.cb_object = callback_object
  endif
  if (n_elements(callback_method) gt 0L) then begin
    self.cb_method = callback_method
  endif
  if (n_elements(polling_cycle) gt 0L) then begin
    self.polling_cycle = polling_cycle
  endif

  if (n_elements(e) gt 0L) then begin
    self->IDL_IDLBridge::setProperty, _strict_extra=e
  endif
end


;+
; Retrieve properties.
;-
pro mg_process::getProperty, name=name, $
                             cb_object=callback_object, $
                             cb_method=callback_method, $
                             polling_cycle=polling_cycle, $
                             _ref_extra=e
  compile_opt strictarr

  if (arg_present(name)) then name = self.name
  if (arg_present(callback_object)) then callback_object = self.cb_object
  if (arg_present(callback_method)) then callback_method = self.cb_method
  if (arg_present(polling_cycle)) then polling_cycle = self.polling_cycle

  if (n_elements(e) gt 0L) then begin
    self->IDL_IDLBridge::getProperty, _strict_extra=e
  endif
end


;= lifecycle methods

;+
; Free resources.
;-
pro mg_process::cleanup
  compile_opt strictarr

  self->IDL_IDLBridge::cleanup
end


;+
; Create a process object.
;
; :Returns:
;   1 for success, 0 for failure
;
; :Keywords:
;   name : in, optional, type=string
;     name for the process
;   cb_object : in, optional, type=object
;     object whose method specified by `cb_method` should be called on task
;     completion
;   cb_method : in, optional, type=string
;     method of `cb_object` that should be called on task completion
;   polling_cycle : in, optional, type=float, default=0.5
;     time, in seconds, to wait before checking again to see if work is
;     completed
;   _extra : in, optional, type=keywords
;     keywords to `IDL_IDLBridge`
;-
function mg_process::init, name=name, $
                           cb_object=callback_object, $
                           cb_method=callback_method, $
                           polling_cycle=polling_cycle, $
                           _extra=e
  compile_opt strictarr

  if (~self->IDL_IDLBridge::init(_extra=e)) then return, 0

  self.polling_cycle = 0.5

  self->setProperty, name=name, $
                     cb_object=callback_object, $
                     cb_method=callback_method, $
                     polling_cycle=polling_cycle, $
                     callback='mg_process_callback'

  return, 1
end


;+
; Class representing a process.
;
; :Fields:
;   name
;     name of the process
;   cb_object
;     object whose method specified by `cb_method` should be called on task
;     completion
;   cb_method
;     method of `cb_object` that should be called on task completion
;-
pro mg_process__define
  compile_opt strictarr

  define = { MG_Process, inherits IDL_IDLBridge, inherits IDL_Object, $
             name: '', $
             cb_object: obj_new(), $
             cb_method: '', $
             polling_cycle: 0.0 $
           }
end

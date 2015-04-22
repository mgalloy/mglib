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


;= property access

;+
; Set properties.
;-
pro mg_process::setProperty, name=name, $
                             cb_object=callback_object, $
                             cb_method=callback_method, $
                             _extra=e
  compile_opt strictarr

  if (n_elements(name) gt 0L) then self.name = name
  if (n_elements(callback_object) gt 0L) then begin
    self.cb_object = callback_object
  endif
  if (n_elements(callback_method) gt 0L) then begin
    self.cb_method = callback_method
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
                             _ref_extra=e
  compile_opt strictarr

  if (arg_present(name)) then name = self.name
  if (arg_present(callback_object)) then callback_object = self.cb_object
  if (arg_present(callback_method)) then callback_method = self.cb_method

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
;   _extra : in, optional, type=keywords
;     keywords to `IDL_IDLBridge`
;-
function mg_process::init, name=name, $
                           cb_object=callback_object, $
                           cb_method=callback_method, $
                           _extra=e
  compile_opt strictarr

  if (~self->IDL_IDLBridge::init(_extra=e)) then return, 0

  self->setProperty, name=name, $
                     cb_object=callback_object, $
                     cb_method=callback_method, $
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

  define = { MG_Process, inherits IDL_IDLBridge, $
             name: '', $
             cb_object: obj_new(), $
             cb_method: '' $
           }
end
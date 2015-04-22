; docformat = 'rst'

;= helper routines/methods

pro mg_process::onCallback, status, error
  compile_opt strictarr

  if (obj_valid(self.callback_object)) then begin
    call_method, self.callback_method, self.callback_object, $
                 self, status, error
  endif
end


;= API




;= property access

pro mg_process::setProperty, name=name, $
                             callback_object=callback_object, $
                             callback_method=callback_method, $
                             _extra=e
  compile_opt strictarr

  if (n_elements(name) gt 0L) then self.name = name
  if (n_elements(callback_object) gt 0L) then begin
    self.callback_object = callback_object
  endif
  if (n_elements(callback_method) gt 0L) then begin
    self.callback_method = callback_method
  endif

  if (n_elements(e) gt 0L) then begin
    self->IDL_IDLBridge::setProperty, _strict_extra=e
  endif
end


pro mg_process::getProperty, name=name, $
                             callback_object=callback_object, $
                             callback_method=callback_method, $
                             _ref_extra=e
  compile_opt strictarr

  if (arg_present(name)) then name = self.name
  if (arg_present(callback_object)) then callback_object = self.callback_object
  if (arg_present(callback_method)) then callback_method = self.callback_method

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
;   _extra : in, optional, type=keywords
;     keywords to `IDL_IDLBridge`
;-
function mg_process::init, name=name, $
                           callback_object=callback_object, $
                           callback_method=callback_method, $
                           _extra=e
  compile_opt strictarr

  if (~self->IDL_IDLBridge::init(_extra=e)) then return, 0

  self->setProperty, name=name, $
                     callback_object=callback_object, $
                     callback_method=callback_method

  return, 1
end


;+
; Class representing a process.
;
; :Fields:
;   name
;     name of the process
;-
pro mg_process__define
  compile_opt strictarr

  define = { MG_Process, inherits IDL_IDLBridge, $
             name: '', $
             callback_object: obj_new(), $
             callback_method: '' $
           }
end
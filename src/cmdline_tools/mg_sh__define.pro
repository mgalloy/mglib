; docformat = 'rst'

;+
; Make a shell call.
;
; :Returns:
;   `strarr`
;
; :Params:
;   cmd : in, required, type=string
;     cmd to run
;   args : in, optional, type=string
;     command line args to `cmd`
;
; :Keywords:
;   error_result : out, optional, type=strarr
;     set to a named variable to retrieve the error output
;   exit_status : out, optional, type=long
;     set to a named variable to retrieve the exit status of the command
;-
function mg_sh::_overloadMethod, cmd, args, $
                                 error_result=error_result, $
                                 exit_status=exit_status
  compile_opt strictarr

  _cmd = strlowcase(cmd)
  if (n_elements(args) gt 0L) then _cmd += ' ' + args

  spawn, _cmd, result, error_result, exit_status=exit_status

  return, result
end


;+
; Allocate shell object.
;
; :Returns:
;   1 for success, 0 otherwise
;-
function mg_sh::init
  compile_opt strictarr

  return, 1
end


;+
; Define instance variables.
;-
pro mg_sh__define
  compile_opt strictarr

  !null = {mg_sh, inherits IDL_Object}
end


; main-level example program

sh = mg_sh()
print, transpose(sh.ls('-lh'))
print, transpose(sh.df('-lh'))

obj_destroy, sh

end

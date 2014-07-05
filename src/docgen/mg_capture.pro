; docformat = 'rst'

;+
; Returns output log output from an IDL command.
;
; :Returns:
;   `strarr`
;
; :Params:
;   cmd : in, required, type=string
;     IDL command to capture output from
;
; :Keywords:
;   status : out, optional, type=long
;     status of IDL command execution
;-
function mg_capture, cmd, status=status
  compile_opt strictarr

  mg_tout_push
  status = execute(cmd)
  output = mg_tout_pop()
  return, mg_strunmerge(output)
end

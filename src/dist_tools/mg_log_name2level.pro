; docformat = 'rst'

;+
; Convert a log level name to a log level code.
;
; :Returns:
;   integer log level code
;
; :Params:
;   name : in, required, type=string
;     case-insensitive name of log level, i.e., 'debug', 'info'/'informational',
;     'warn'/'warning', 'error', 'critical'
;-
function mg_log_name2level, name
  compile_opt strictarr

  switch strlowcase(name) of
    'debug': begin
        code = 5
        break
      end
    'info':
    'informational': begin
        code = 4
        break
      end
    'warn':
    'warning': begin
        code = 3
        break
      end
    'error': begin
        code = 2
        break
      end
    'critical': begin
        code = 1
        break
      end
    else: code = 5
  endswitch

  return, code
end

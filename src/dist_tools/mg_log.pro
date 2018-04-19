; docformat = 'rst'

;+
; `MG_LOG` is a procedural interface to the logging framework.
;
; `MG_LOG` is a convenience routine so that the `MGffLogger` object does not
; need to be explicitly stored by the application using the logging. If more
; than one logger is required, then named loggers can be used using the `NAME`
; keyword.
;
; The error levels are: critical (level 1), error (level 2), warning
; (level 3), informational (level 4), debug (level 5). Only log messages with
; a level less than or equal to the current logger level are actually
; recorded. So if a logger is set to level 3 (warnings), then log messages
; with levels 1 (critical), 2 (error), or 3 (warning) would be displayed, but
; log messages with levels 4 (informational) or 5 (debug) would be ignored.
;
; Named subloggers can be created using the `NAME` keyword. These subloggers
; should be used for individual applications or functional areas of an
; application.
;
; For example, the following starts the logging framework and creates a
; logger object with name "mg_example" returned via the `LOGGER` keyword::
;
;    mg_log, name='mg_example', logger=logger
;
; This logger would next be configured, i.e., set its level, specify a file
; for log messages to written to, set a format for log messages, etc. For
; example, to log critical errors, errors, and warnings to the file
; `my_application.log`, do::
;
;   logger->setProperty, level=3, filename='my_application.log'
;
; Later, messages can be sent to this logger by using the name used
; previously::
;
;   mg_log, 'A problem occurred!', /warning, name='mg_example'
;
; Further refinement can be done with a hierarchy of names. The following
; creates a new sublogger::
;
;   mg_log, name='mg_example/gui', logger=gui_logger
;
; This type of hierarchy is useful for applications with subsystems with
; independent level values. The effective log level for log messages sent to a
; sublogger is the least restrictive log level from all the parent loggers. For
; example, if the level of `gui_logger` was set to "Informational" with::
;
;   gui_logger->setProperty, level=4
;
; Then informational log messages would be logged even though the parent
; logger, "mg_example", has a level of 3, i.e., "Warning".
;
; :Examples:
;   Try the main-level program at the end of this file for a longer example.
;   To run it, do::
;
;     IDL> .run mg_log
;-


;+
; Messages are logged via this routine. Also, the `LOGGER` keyword returns the
; logging object which is used to configure the logging.
;
; :Params:
;   msg : in, optional, type=string
;     message to log, if present; is interpreted as a format string when
;     additional parameters are present
;   arg1 : in, optional, type=string
;     optional argument to be substituted into `msg` format string
;   arg2 : in, optional, type=string
;     optional argument to be substituted into `msg` format string
;   arg3 : in, optional, type=string
;     optional argument to be substituted into `msg` format string
;   arg4 : in, optional, type=string
;     optional argument to be substituted into `msg` format string
;   arg5 : in, optional, type=string
;     optional argument to be substituted into `msg` format string
;   arg6 : in, optional, type=string
;     optional argument to be substituted into `msg` format string
;   arg7 : in, optional, type=string
;     optional argument to be substituted into `msg` format string
;   arg8 : in, optional, type=string
;     optional argument to be substituted into `msg` format string
;   arg9 : in, optional, type=string
;     optional argument to be substituted into `msg` format string
;   arg10 : in, optional, type=string
;     optional argument to be substituted into `msg` format string
;   arg11 : in, optional, type=string
;     optional argument to be substituted into `msg` format string
;   arg12 : in, optional, type=string
;     optional argument to be substituted into `msg` format string
;
; :Keywords:
;   name : in, optional, type=string
;     path to logger to send message to
;   critical : in, optional, type=boolean
;     set to specify the message as critical
;   error : in, optional, type=boolean
;     set to specify the message as an error
;   warning : in, optional, type=boolean
;     set to specify the message as a warning
;   informational : in, optional, type=boolean
;     set to specify the message as informational
;   debug : in, optional, type=boolean
;     set to specify the message as debug
;   check_math : in, optional, type=boolean
;     set to put a message about the current `CHECK_MATH` state in the log, if
;     the current state is not 0
;   last_error : in, optional, type=boolean
;     set to place a stack trace for the last error in the log; placed after
;     the logging of any normal message in this call
;   execution_info : in, optional, type=boolean
;     set to place a stack trace in the log; placed after the logging
;     of any normal message in this call
;   logger : out, optional, type=object
;     `MGffLogger` object
;   was_logged : out, optional, type=boolean
;     set to a named variable to retrieve whether the message was logged
;   quit : in, optional, type=boolean
;     set to quit logging; will log an normal message in this call before
;       quitting
;   _extra : in, optional, type=keywords
;     keywords to `MGffLogger::setProperty` to configure the logger
;-
pro mg_log, msg, $
            arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, $
            arg11, arg12, $
            name=name, $
            debug=debug, informational=informational, $
            warning=warning, error=error, critical=critical, $
            check_math=check_math, $
            last_error=lastError, $
            execution_info=execution_info, $
            logger=logger, was_logged=was_logged, quit=quit, _extra=e
  compile_opt strictarr
  on_error, 2
  on_ioerror, format_error
  @mg_log_common

  case n_params() of
    0: _msg = ''
    1: _msg = msg
    2: _msg = string(arg1, format='(%"' + msg + '")')
    3: _msg = string(arg1, arg2, format='(%"' + msg + '")')
    4: _msg = string(arg1, arg2, arg3, format='(%"' + msg + '")')
    5: _msg = string(arg1, arg2, arg3, arg4, format='(%"' + msg + '")')
    6: _msg = string(arg1, arg2, arg3, arg4, arg5, format='(%"' + msg + '")')
    7: _msg = string(arg1, arg2, arg3, arg4, arg5, arg6, format='(%"' + msg + '")')
    8: _msg = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, format='(%"' + msg + '")')
    9: _msg = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, format='(%"' + msg + '")')
    10: _msg = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, format='(%"' + msg + '")')
    11: _msg = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, format='(%"' + msg + '")')
    12: _msg = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, format='(%"' + msg + '")')
    13: _msg = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, format='(%"' + msg + '")')
  endcase

  ; create the top-level logger if it doesn't already exist in the
  ; mg_log_common common block
  if (~obj_valid(mgLogger)) then mgLogger = obj_new('MGffLogger', level=0)

  ; use (optional) name to lookup actual logger or use the top-level logger
  ; if not named
  logger = n_elements(name) eq 0L ? mgLogger : mgLogger->getByName(name)

  ; pass on keywords to the logger
  logger->setProperty, _strict_extra=e

  ; set the level of the message
  levels = [keyword_set(critical), $
            keyword_set(error), $
            keyword_set(warning), $
            keyword_set(informational), $
            keyword_set(debug)]
  _level = max(levels * (lindgen(5) + 1L))
  if (_level eq 0L) then _level = 5L  ; default level is DEBUG

  ; log messages
  was_logged = 0B
  if (n_params() gt 0L && obj_valid(logger)) then begin
    logger->print, _msg, level=_level, back_levels=1, was_logged=was_logged
  endif

  ; insert execution info at same level if requested
  if (keyword_set(execution_info)) then begin
    logger->insert_execution_info, level=_level, back_levels=1
  endif

  ; do after regular messages so that a regular message and the CHECK_MATH
  ; status/stack trace can be logged with one call to MG_LOG
  if (keyword_set(check_math)) then logger->insertCheckMath, back_levels=1, level=_level
  if (keyword_set(lastError)) then logger->insertLastError, back_levels=1

  ; do last so that a quitting message can be logged at the same time that the
  ; logger is shutdown
  if (keyword_set(quit)) then obj_destroy, logger

  return
  format_error:
  message, 'format error'
end


; main-level example program

mg_log, logger=logger

print, 'Top level logger @ LEVEL=5 (DEBUG):'
mg_log, 'Debugging message', /debug
mg_log, 'Informational message', /informational
mg_log, 'Warning message', /warning
mg_log, 'Error message', /error
mg_log, 'Critical message', /critical

logger->setProperty, /warning

print
print, 'Top level logger @ LEVEL=3 (WARNING):'
mg_log, 'Debugging message', /debug              ; won't show up since LEVEL=3
mg_log, 'Informational message', /informational  ; won't show up since LEVEL=3
mg_log, 'Warning message', /warning
mg_log, 'Error message', /error
mg_log, 'Critical message', /critical

logger->setProperty, /critical

print
print, 'mg_log logger @ LEVEL=1 (CRITICAL):'
mg_log, 'Debugging message', /debug      ; won't show up since LEVEL=1
mg_log, 'Informational message', /info   ; won't show up since LEVEL=1
mg_log, 'Warning message', /warning      ; won't show up since LEVEL=1
mg_log, 'Error message', /error          ; won't show up since LEVEL=1
mg_log, 'Critical message', /critical

mg_log, /quit

end

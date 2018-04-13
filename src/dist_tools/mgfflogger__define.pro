; docformat = 'rst'

;+
; Logger object to control logging.
;
; :Properties:
;   name : type=string
;     name of the logger
;   parent : private
;     parent logger
;   level : type=long
;     current level of logging: 0 (not set), 1 (critical), 2 (error),
;     3 (warning), 4 (info), or 5 (debug); can be set to an array of levels
;     which will be cascaded up to the parents of the logger with the logger
;     taking the last level and passing the previous ones up to its parent;
;     only messages with levels greater than or equal to than the logger
;     level will be logged
;   debug : type=boolean
;     convenience keyword to set level as debug (5)
;   informational : type=boolean 
;     convenience keyword to set level as informational (4)
;   warning : type=boolean
;     convenience keyword to set level as warning (3)
;   error : type=boolean
;     convenience keyword to set level as error (2)
;   critical : type=boolean
;     convenience keyword to set level as critical (1)
;   color : type=boolean
;     set to use color for logging to TTY
;   time_format : type=string
;       Fortran style format code to specify the format of the time in the
;       `FORMAT` property; the default value formats the time/date like
;       "2003-07-08 16:49:45.891"
;   format : type=string
;     format string for messages, default value for format is::
;
;       '%(time)s %(levelshortname)s: %(routine)s: %(message)s'
;
;     where the possible names to include are: "time", "levelname",
;     "levelshortname", "routine", "stacktrace", "name", "fullname" and
;     "message".
;
;     Note that the "time" argument will first be formatted using the
;     `TIME_FORMAT` specification
;   filename : type=string
;     filename to send append output to; set to empty string to send output
;     to `stderr`
;   widget_identifier : type=long
;     if set to a positive integer, append output to the corresponding
;     WIDGET_TEXT
;   clobber : type=boolean
;     set, along with filename, to clobber pre-existing file
;   output : type=strarr
;     output sent to the logger already
;   _extra : type=keywords
;     any keyword accepted by `MGffLogger::setProperty`
;-



;+
; Determines if the current terminal is a TTY, calling `MG_TERMISTTY` safely
; even if `mglib` is not installed.
;
; :Private:
;
; :Returns:
;   1 if current term is a TTY, 0 if not (or not sure)
;-
function mgfflogger::_is_tty
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    message, /reset
    return, 0
  endif

  return, mg_termIsTty()
end


;+
; Get the maximum level value of this logger and all its parents. Level 0 is
; not set and is not used in the calculation.
;
; :Private:
;
; :Returns:
;    long
;-
function mgfflogger::_getLevel
  compile_opt strictarr

  return, obj_valid(self.parent) $
            ? (self.level eq 0 $
              ? (self.parent->_getLevel()) $
              : (self.parent->_getLevel() > self.level)) $
            : self.level
end


;+
; Finds the name of an object, even if it does not have a `NAME` property.
; Returns the empty string if the object does not have a `NAME` property.
;
; :Private:
;
; :Returns:
;    string
;
; :Params:
;    obj : in, required, type=object
;       object to find name of
;-
function mgfflogger::_askName, obj
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, ''
  endif

  obj->getProperty, name=name
  return, name
end


;+
; Returns an immediate child of a container by name.
;
; :Private:
;
; :Returns:
;    object
;
; :Params:
;    name : in, required, type=string
;       name of immediate child
;    container : in, required, type=object
;       container to search children of
;-
function mgfflogger::_getChildByName, name, container
  compile_opt strictarr

  for i = 0L, container.children->count() - 1L do begin
    child = container.children->get(position=i)
    childName = self->_askName(child)
    if (childName eq name) then return, child
  endfor

  return, obj_new()
end


;+
; Traverses a hierarchy of named objects using a path of names delimited with
; /'s.
;
; :Returns:
;    object
;
; :Params:
;    name : in, required, type=string
;       path of names to the desired object; names are delimited with /'s
;-
function mgfflogger::getByName, name
  compile_opt strictarr

  tokens = strsplit(name, '/', /extract, count=ntokens)
  child = self
  for depth = 0L, ntokens - 1L do begin
    newChild = self->_getChildByName(tokens[depth], child)
    if (~obj_valid(newChild)) then begin
      newChild = obj_new('MGffLogger', name=tokens[depth], parent=child)
      child.children->add, newChild
    endif
    child = newChild
  endfor

  return, child
end


;+
; Set properties.
;-
pro mgfflogger::getProperty, level=level, $
                             color=color, $
                             format=format, time_format=time_format, $
                             name=name, $
                             fullname=fullname, $
                             filename=filename, $
                             output=output, children=children
  compile_opt strictarr

  if (arg_present(level)) then level = self.level
  if (arg_present(color)) then color = self.color
  if (arg_present(children)) then children = self.children
  if (arg_present(format)) then format = self.format
  if (arg_present(time_format)) then time_format = self.time_format
  if (arg_present(name)) then name = self.name
  if (arg_present(fullname)) then begin
    if (obj_valid(self.parent)) then begin
      self.parent->getProperty, fullname=parent_fullname
      parent_fullname += '/'
    endif else parent_fullname = ''
    fullname = parent_fullname + self.name
  endif
  if (arg_present(filename)) then filename = self.filename
  if (arg_present(output)) then begin
    if (self.filename ne '') then begin
      output = strarr(file_lines(self.filename))
      openr, lun, self.filename, /get_lun
      readf, lun, output
    endif
  endif
end


;+
; Get properties.
;-
pro mgfflogger::setProperty, level=level, $
                             debug=debug, $
                             informational=informational, $
                             warning=warning, $
                             error=error, $
                             critical=critical, $
                             color=color, $
                             format=format, time_format=time_format, $
                             filename=filename, $
                             widget_identifier=widget_identifier, $
                             clobber=clobber
  compile_opt strictarr

  case n_elements(level) of
    0:
    1: self.level = level
    else: begin
        self.level = level[n_elements(level) - 1L]
        if (obj_valid(self.parent)) then begin
          self.parent->setProperty, level=level[0:n_elements(level) - 2L]
        endif
      end
  endcase

  if (keyword_set(debug)) then self.level = 5
  if (keyword_set(informational)) then self.level = 4
  if (keyword_set(warning)) then self.level = 3
  if (keyword_set(error)) then self.level = 2
  if (keyword_set(critical)) then self.level = 1

  if (n_elements(color) gt 0L) then begin
    self.color = color
    self.color_set = 1B
  endif

  if (n_elements(format) gt 0L) then self.format = format
  if (n_elements(time_format) gt 0L) then self.time_format = time_format
  if (n_elements(filename) gt 0L) then self.filename = filename
  if (n_elements(widget_identifier) gt 0L) then begin
    self.widget_identifier = widget_identifier
  endif
  if (keyword_set(clobber) && n_elements(filename) gt 0L) then begin
    if (file_test(filename)) then file_delete, filename
  endif
end


;+
; Insert the stack trace for the last error message into the log. Since stack
; traces are from run-time crashes they are considered to be at the CRITICAL
; level.
;
; :Keywords:
;    back_levels : in, optional, private, type=boolean
;       number of levels to go back in the stack trace beyond the normal ones;
;       should be set to 1 if calling this routine from `MG_LOG` for example
;-
pro mgfflogger::insertLastError, back_levels=back_levels
  compile_opt strictarr

  _back_levels = n_elements(back_levels) eq 0L ? 0 : back_levels

  help, /last_message, output=helpOutput
  if (n_elements(helpOutput) eq 1L && helpOutput[0] eq '') then return

  self->print, 'Stack trace for error', level=1, back_levels=_back_levels + 1L
  self->print, transpose(helpOutput), level=1, /no_header
end


;+
; Insert stack trace into log.
;
; :Keywords:
;   level : in, optional, type=long
;     level of message
;   back_levels : in, optional, private, type=boolean
;     number of levels to go back in the stack trace beyond the normal ones;
;     should be set to 1 if calling this routine from `MG_LOG` for
;     example
;-
pro mgfflogger::insert_execution_info, level=level, back_levels=back_levels
  compile_opt strictarr

  _back_levels = n_elements(back_levels) eq 0L ? 0 : back_levels
  s = scope_traceback(/system)
  s = s[0:n_elements(s) - 2L - back_levels]
  self->print, transpose(s), level=level, /no_header
end


;+
; Log message to given level.
;
; :Params:
;   msg : in, required, type=string
;     message to print
;
; :Keywords:
;   level : in, optional, type=long
;     level of message
;   back_levels : in, optional, private, type=boolean
;     number of levels to go back in the stack trace beyond the normal ones;
;     should be set to 1 if calling this routine from `MG_LOG` for
;     example
;   no_header : in, optional, type=boolean
;     set to not print header information
;   was_logged : out, optional, type=boolean
;     set to a named variable to retrieve whether the message was logged
;-
pro mgfflogger::print, msg, level=msg_level, back_levels=back_levels, $
                       no_header=no_header, was_logged=was_logged
  compile_opt strictarr
  on_error, 2

  was_logged = 0B

  _back_levels = n_elements(back_levels) eq 0L ? 0 : back_levels

  if (self.filename eq '') then begin
    lun = -2L
  endif else begin
    if (file_test(self.filename)) then begin
      openu, lun, self.filename, /get_lun, /append
    endif else begin
      openw, lun, self.filename, /get_lun
    endelse
  endelse

  logger_level = self->_getLevel()
  if ((logger_level eq 0L) or (msg_level le logger_level)) then begin
    if (keyword_set(no_header)) then begin
      s = msg
    endif else begin
      stack = scope_traceback(/structure, /system)
      self->getProperty, fullname=fullname
      vars = { time: string(systime(/julian), $
                            format='(' + self.time_format + ')'), $
               levelname: strupcase(self.levelNames[msg_level - 1L]), $
               levelshortname: strupcase(self.levelShortNames[msg_level - 1L]), $
               routine: stack[n_elements(stack) - 2L - _back_levels].routine, $
               line: stack[n_elements(stack) - 2L - _back_levels].line, $
               stacktrace: strjoin(stack[0:n_elements(stack) - 2L - _back_levels].routine, $
                                   '->'), $
               name: self.name, $
               fullname: fullname, $
               message: msg $
             }
      s = mg_subs(self.format, vars)
    endelse

    if (self.widget_identifier gt 0L) then begin
      widget_control, self.widget_identifier, set_value=s, /append
    endif else begin
      ; use color if set or display to stdout
      if ((self.color_set && self.color) || (~self.color_set && self.is_tty && lun lt 0)) then begin
        case msg_level of
          1: s = mg_ansicode(s, /red)
          2: s = mg_ansicode(s, /magenta)
          3: s = mg_ansicode(s, /yellow)
          4: s = mg_ansicode(s, /cyan)
          5:
        endcase
      endif

      printf, lun, s
    endelse

    was_logged = 1B
  endif

  if (lun ge 0L) then free_lun, lun
end


;+
; Free resources.
;-
pro mgfflogger::cleanup
  compile_opt strictarr

  if (obj_valid(self.parent)) then begin
    (self.parent).children->remove, self
  endif

  obj_destroy, self.children
end


;+
; Create logger object.
;
; :Returns:
;    1 for success, 0 for failure
;-
function mgfflogger::init, parent=parent, name=name, _extra=e
  compile_opt strictarr

  self.parent = n_elements(parent) eq 0L ? obj_new() : parent
  self.name = n_elements(name) eq 0L ? '' : name
  self.children = obj_new('IDL_Container')

  self.time_format = 'C(CYI4.4, "-", CMOI2.2, "-", CDI2.2, " ", CHI2.2, ":", CMI2.2, ":", CSI2.2)'
  self.format = '%(time)s %(levelshortname)s: %(routine)s: %(message)s'

  ; settings to determine whether to use color
  self.is_tty = self->_is_tty()
  self.color = 0B
  self.color_set = 0B

  self.level = 0L
  self.levelNames = ['Critical', 'Error', 'Warning',  'Informational', 'Debug']
  self.levelShortNames = ['Critical', 'Error', 'Warn',  'Info', 'Debug']

  self->setProperty, _extra=e

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    parent
;       parent `MGffLoffer` object
;    name
;       name of the logger
;    children
;       `IDL_Container` of children loggers
;    level
;       current level of logging: 0=none, 1=critical, 2=error, 3=warning,
;       4=informational, or 5=debug; only messages with a level lower or equal
;       to this this value will be logged
;    levelNames
;       names for the different levels
;    levelShortNames
;       shorter names for the different levels
;    filename
;       filename to send output to
;    time_format
;       Fortran format codes for calendar output
;    format
;       format code to send output to
;-
pro mgfflogger__define
  compile_opt strictarr

  define = { MGffLogger, inherits IDL_object, $
             parent: obj_new(), $
             name: '', $
             children: obj_new(), $
             level: 0L, $
             levelNames: strarr(5), $
             levelShortNames: strarr(5), $
             color: 0B, $
             color_set: 0B, $
             is_tty: 0B, $
             filename: '', $
             widget_identifier: 0L, $
             time_format: '', $
             format: '' $
           }
end

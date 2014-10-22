; docformat = 'rst'

;+
; An object to facilitate parsing of command line options.
;
; :Examples:
;   Try::
;
;     ; create options object
;     opts = obj_new('mg_options', app_name='mg_options_example', version='1.0')
;
;     ; setup options
;     opts->addOption, 'verbose', 'v', $
;                      /boolean, $
;                      help='set to print a verbose greeting'
;     opts->addOption, 'name', 'n', help='name of user to greet', default='Mike', $
;                        metavar='user''s name'
;
;     ; parse the options
;     opts->parseArgs, error_message=errorMsg
;
;     if (errorMsg ne '') then begin
;       oldQuiet = !quiet
;       !quiet = 0
;       message, errorMsg, /informational, /noname
;       !quiet = oldQuiet
;     end
;
;     if (errorMsg eq '' && ~opts->get('help') && ~opts->get('version')) then begin
;       print, (opts->get('verbose') ? 'Greetings and salutations' : 'Hello'), $
;              opts->get('name'), $
;              format='(%"%s, %s!")'
;     endif
;
;     ; destroy the options when done
;     obj_destroy, opts
;
; :Uses:
;   `MGcoHashTable`
;
; :Requires:
;   IDL 6.2
;-


; Class definition for a helper object representing individual option
; definitions.

;+
; Set properties.
;
; :Private:
;-
pro mg_opt::setProperty, short_name=shortName
  compile_opt strictarr

  if (n_elements(shortName) gt 0L) then begin
    self.shortName = shortName
  endif
end


;+
; Get properties.
;
; :Private:
;-
pro mg_opt::getProperty, long_name=longName, short_name=shortName, $
                         boolean=boolean, metavar=metavar, $
                         key_column_width=keyColumnWidth, $
                         help_header=helpHeader
  compile_opt strictarr

  if (arg_present(longName)) then longName = self.longName
  if (arg_present(shortName)) then shortName = self.shortName
  if (arg_present(boolean)) then boolean = self.boolean
  if (arg_present(metavar)) then metavar = self.metavar

  if (arg_present(keyColumnWidth) || arg_present(helpHeader)) then begin
    helpHeader = '--' + self.longName
    helpText = self.metavar eq '' ? strupcase(self.longName) : self.metavar

    if (~self.boolean) then begin
      helpHeader += '=' + helpText
    endif

    if (self.shortName ne '') then begin
      helpHeader += ', -' + self.shortName

      if (~self.boolean) then helpHeader += ' ' + helpText
    endif

    keyColumnWidth = strlen(helpHeader)
  endif
end


;+
; Returns whether the option has had a value set i.e. it is present on the
; current command line.
;
; :Private:
;
; :Returns:
;    byte
;-
function mg_opt::isPresent
  compile_opt strictarr

  return, self.present
end


;+
; Returns the help text for the option.
;
; :Private:
;
; :Returns:
;   string
;-
function mg_opt::getHelp
  compile_opt strictarr

  return, self.help
end


;+
; Get value of the option.
;
; :Private:
;
; :Returns:
;   string (normally) or byte (if boolean)
;
; :Keywords:
;   present : out, optional, type=boolean
;     set to a named variable to determine if the option is present
;-
function mg_opt::getValue, present=present
  compile_opt strictarr

  present = self.present

  if (self.boolean) then begin
    return, self.present ? 1B : 0B
  endif else begin
    return, self.present ? self.value : self.default
  endelse
end


;+
; Set the value of the option.
;
; :Private:
;
; :Params:
;   value : in, optional, type=string
;     value of the option
;-
pro mg_opt::setValue, value
  compile_opt strictarr
  on_error, 2

  self.present = 1B
  if (n_elements(value) gt 0L) then begin
    self.value = value
  endif else begin
    if (~self.boolean) then begin
      message, 'non-boolean options like --' + self.longName + ' must have a value if present'
    endif
  endelse
end


;+
; Create an option.
;
; :Private:
;
; :Returns:
;   1 for success, 0 for failure
;
; :Keywords:
;   long_name : in, required, type=string
;     long name of the option
;   boolean : in, optional, type=boolean
;     set to indicate the option is boolean i.e. it does not take a value,
;     being present "sets" it
;   help : in, optional, type=string, default=''
;     help text to display for the option
;   default : in, optional, type=string, default=''
;     default value of the option
;   metavar : in, optional, type=string
;     text to display in the help for non-boolean option values
;-
function mg_opt::init, long_name=longName, boolean=boolean, $
                       help=help, default=default, metavar=metavar
  compile_opt strictarr

  self.longName = longName
  self.boolean = keyword_set(boolean)
  self.help = n_elements(help) gt 0L ? help : ''
  self.default = n_elements(default) gt 0L ? default : ''
  self.metavar = n_elements(metavar) gt 0L ? metavar : ''

  return, 1
end


;+
; Define instance variables.
;
; :Private:
;
; :Fields:
;   longName
;     long name of the option
;   shortName
;     single character abbreviation for the option
;   value
;     value of the option
;   present
;     true if value has been set
;   boolean
;     true if option is a boolean type option
;   metavar
;     text to display in the help for non-boolean option values
;   help
;     text to print for the option if help is asked for
;   default
;     default value if value is not present
;-
pro mg_opt__define
  compile_opt strictarr

  define = { mg_opt, $
             longName: '', $
             shortName: '', $
             value: '', $
             present: 0B, $
             boolean: 0B, $
             metavar: '', $
             help: '', $
             default: '' }
end


; Definition of mg_options class

;+
; Get value of option.
;
; :Returns:
;   string
;
; :Params:
;   optname : in, required, type=string
;     long name of option
;
; :Keywords:
;   params : in, optional, type=boolean
;     set to return parameters
;   n_params : out, optional, type=long
;     number of parameters returned, only used if PARAMS is set
;   present : out, optional, type=boolean
;     set to a named variable to determine if the option was present
;-
function mg_options::get, optname, params=params, n_params=nparams, $
                          present=present
  compile_opt strictarr
  on_error, 2

  if (keyword_set(params)) then return, self.params->get(/all, count=nparams)

  opt = self.longOptions->get(optname, found=found)
  if (~found) then message, string(optname, format='(%"option %s not found")')
  return, opt->getValue(present=present)
end


;+
; Display the help for the defined options.
;
; :Private:

;-
pro mg_options::_displayHelp
  compile_opt strictarr

  keys = self.longOptions->keys(count=nkeys)
  shortNames = self.shortOptions->keys(count=nshortNames)

  args = ''
  if (self.nparamsAccepted[0] gt 0L) then begin
    args += strjoin('arg' + strtrim(indgen(self.nparamsAccepted[0]) + 1, 2), ' ')
  endif

  case 1 of
    self.nParamsAccepted[1] lt 0L: args += '...'
    self.nParamsAccepted[1] eq 0L:
    self.nParamsAccepted[1] gt 0L: begin
        if (self.nparamsAccepted[1] gt self.nparamsAccepted[0]) then begin
          optionalArgIndices $
            = indgen(self.nparamsAccepted[1] - self.nparamsAccepted[0]) $
                + self.nparamsAccepted[0]
          if (args ne '') then args += ' '
          args += strjoin('[arg' + strtrim(optionalArgIndices, 2) + ']', ' ')
        endif
      end
  endcase

  print, self.appname, args, format='(%"usage: %s [options] %s")'
  print

  keyColumnWidth = 2L
  maxKeyColumnWidth = 24L
  for k = 0L, nkeys - 1L do begin
    opt = self.longOptions->get(keys[k])
    opt->getProperty, key_column_width=keyWidth
    keyColumnWidth >= keyWidth
  endfor

  keyColumnWidth = keyColumnWidth < maxKeyColumnWidth
  combinedFormat = '(%"  %-' + strtrim(keyColumnWidth, 2L) + 's  %s")'
  splitFormat1 = '(%"  %-0s")'
  splitFormat2 = '(%"' + strjoin((strarr(maxKeyColumnWidth + 4L) + ' ')) + '%s")'

  print, 'options:'
  keyind = sort(keys)
  for k = 0L, nkeys - 1L do begin
    opt = self.longOptions->get(keys[keyind[k]])
    opt->getProperty, help_header=helpHeader
    if (strlen(helpHeader) gt maxKeyColumnWidth) then begin
      print, helpHeader, format=splitFormat1
      print, opt->getHelp(), format=splitFormat2
    endif else begin
      print, helpHeader, opt->getHelp(), format=combinedFormat
    endelse
  endfor
end


;+
; Print version information.
;
; :Private:
;-
pro mg_options::_displayVersion
  compile_opt strictarr

  print, self.appname, self.version, format='(%"%s %s")'
end


;+
; Parse arguments.
;
; :Params:
;   args : in, optional, type=strarr, default=command_line_args()
;     string array of arguments
;
; :Keywords:
;   error_message : out, optional, type=string
;     set to a named variable to receive any error message generated from
;     parsing the parameters
;-
pro mg_options::parseArgs, args, error_message=errorMsg
  compile_opt strictarr

  errorMsg = ''

  _args = n_elements(args) eq 0L ? command_line_args(count=nargs) : args
  _nargs = n_elements(nargs) eq 0L ? n_elements(args) : nargs

  argumentExpected = 0B

  for a = 0L, _nargs - 1L do begin
    ; set an option value from the last token in the argument list
    if (argumentExpected) then begin
      opt->setValue, _args[a]
      argumentExpected = 0B
      continue
    endif

    ; long form
    if (strpos(_args[a], '--') eq 0L) then begin
      equalpos = strpos(_args[a], '=')
      if (equalpos eq -1L) then begin
        optname = strmid(_args[a], 2L)
      endif else begin
        optname = strmid(_args[a], 2L, equalpos - 2L)
      endelse

      opt = self.longOptions->get(optname, found=found)
      opt->getProperty, boolean=boolean

      if (~found) then begin
        errorMsg = string(optname, format='(%"unknown option: --%s")')
        return
      endif

      if (boolean) then begin
        opt->setValue
      endif else begin
        if (equalpos eq -1L) then begin
          argumentExpected = 1B
        endif else begin
          opt->setValue, strmid(_args[a], equalpos + 1L)
        endelse
      endelse

      continue
    endif

    ; short form
    if (strpos(_args[a], '-') eq 0L) then begin
      for sf = 1L, strlen(_args[a]) - 1L do begin
        shortName = strmid(_args[a], sf, 1)
        opt = self.shortOptions->get(shortName, found=found)

        if (~found) then begin
          errorMsg = string(shortName, format='(%"unknown option: -%s")')
          return
        endif

        opt->getProperty, boolean=boolean
        if (boolean) then begin
          opt->setValue
        endif else begin
          ; short name option with value must be the last one
          if (sf ne strlen(_args[a]) - 1L) then begin
            msg = '(%"non-boolean option -%s must be specified last to accept a value")'
            errorMsg = string(shortName, format=msg)
            return
          endif
          argumentExpected = 1B
        endelse
      endfor

      continue
    endif

    ; argument
    self.params->add, _args[a]
  endfor

  if (argumentExpected) then begin
    errorMsg = string(_args[a - 1L], format='(%"argument expected for %s")')
    return
  endif

  helpOpt = self.longOptions->get('help')
  if (helpOpt->isPresent()) then self->_displayHelp

  versionOpt = self.longOptions->get('version', found=versionFound)
  if (versionFound && versionOpt->isPresent()) then self->_displayVersion

  if (helpOpt->isPresent() || (versionFound && versionOpt->isPresent())) then return

  nparams = self.params->count()
  if (nparams lt self.nParamsAccepted[0]) then begin
    errorMsg = string(self.nParamsAccepted[0], nparams, $
                      format='(%"%d parameters required, %d given")')
    return
  endif

  if (self.nParamsAccepted[1] ge 0L && nparams gt self.nParamsAccepted[1]) then begin
    errorMsg = string(self.nParamsAccepted[1], nparams, $
                      format='(%"%d parameters allowed, %d given")')
    return
  endif
end


;+
; Add the definition of an option to the parser.
;
; :Params:
;   longForm : in, required, type=string
;     long name of the option, used with two dashes i.e. --help
;   shortForm : in, optional, type=string
;     single character name of an option, used with a single dash i.e. -h
;
; :Keywords:
;   boolean : in, optional, type=boolean
;     set to indicate the option is a boolean switch
;   help : in, optional, type=string
;     help text for the option
;   default : in, optional, type=string
;     default value
;   metavar : in, optional, type=string
;     text to display in the help for non-boolean option values
;-
pro mg_options::addOption, longForm, shortForm, help=help, default=default, $
                           boolean=boolean, metavar=metavar
  compile_opt strictarr

  opt = obj_new('mg_opt', $
                long_name=longForm, $
                boolean=boolean, help=help, default=default, metavar=metavar)
  self.longOptions->put, longForm, opt
  if (n_elements(shortForm) gt 0L) then begin
    self.shortOptions->put, shortForm, opt
    opt->setProperty, short_name=shortForm
  endif
end


;+
; Add a range of positional parameters.
;
; :Params:
;   nparamsRange : in, required, type=lonarr(2)
;     valid range for number of positional parameters, use -1 for the max
;     value to allow an unlimited number of parameters
;-
pro mg_options::addParams, nparamsRange
  compile_opt strictarr
  on_error, 2

  if (nparamsRange[0] lt 0L) then begin
    message, 'minimum number of params must be positive'
  endif

  if (nparamsRange[1] gt 0L && (nparamsRange[1] lt nparamsRange[0])) then begin
    message, 'maximum number of params must be greater than minimum number'
  endif

  self.nParamsAccepted = nparamsRange
end


;+
; Free resources.
;-
pro mg_options::cleanup
  compile_opt strictarr

  ; free individual options objects
  opts = self.longOptions->values(count=count)
  if (count gt 0L) then obj_destroy, opts

  ; free hash tables of options
  obj_destroy, [self.longOptions, self.shortOptions, self.params]
end


;+
; Create option parsing object.
;
; :Returns:
;   1 for success, 0 for failure
;
; :Keywords:
;   app_name : in, optional, type=string, default=''
;     application name
;   version : in, optional, type=string
;     version of the application
;-
function mg_options::init, app_name=appname, version=version
  compile_opt strictarr

  self.appname = n_elements(appname) eq 0L ? 'app' : appname
  self.version = n_elements(version) eq 0L ? '' : version

  self.longOptions = obj_new('MGcoHashTable', key_type=7, value_type=11)
  self.shortOptions = obj_new('MGcoHashTable', key_type=7, value_type=11)
  self.params = obj_new('MGcoArrayList', type=7)

  self->addOption, 'help', 'h', /boolean, help='display this help'
  if (self.version ne '') then begin
    self->addOption, 'version', /boolean, help='display version information'
  endif

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;   longOptions
;     hash table of options keyed on long name of option
;   shortOptions
;     hash table of options keyed on short name of option, if present
;-
pro mg_options__define
  compile_opt strictarr

  define = { mg_options, $
             appname: '', $
             version: '', $
             longOptions: obj_new(), $
             shortOptions: obj_new(), $
             params: obj_new(), $
             nParamsAccepted: lonarr(2) $
           }
end


; main-level example program

;+
; Execute this program with something like::
;
;   idl -IDL_QUIET 1 -quiet -e ".run mg_options__define" -args --verbose --name=Mike
;
; or::
;
;   idl -IDL_QUIET 1 -quiet -e ".run mg_options__define" -args --help
;-

; create options object
opts = obj_new('mg_options', app_name='mg_options_example', version='1.0')

; setup options
opts->addOption, 'verbose', 'v', $
                 /boolean, $
                 help='set to print a verbose greeting'
opts->addOption, 'name', 'n', help='name of user to greet', default='Mike', $
                 metavar='user''s name'

; parse the options
opts->parseArgs, error_message=errorMsg

if (errorMsg ne '') then begin
  oldQuiet = !quiet
  !quiet = 0
  message, errorMsg, /informational, /noname
  !quiet = oldQuiet
end

if (errorMsg eq '' && ~opts->get('help') && ~opts->get('version')) then begin
  print, (opts->get('verbose') ? 'Greetings and salutations' : 'Hello'), $
         opts->get('name'), $
         format='(%"%s, %s!")'
endif

; destroy the options when done
obj_destroy, opts

end

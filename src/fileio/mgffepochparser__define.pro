; docformat = 'rst'

;= helper routines

;+
; Produce an `mg_datetime` object from a string specification, or another
; `mg_datetime` object.
;
; :Returns:
;   `mg_datetime` object
;
; :Params:
;   datetime : in, required, type=string/object
;     a datetime represented by an `mg_datetime` object or a string with the
;     format 'YYYYMMDD' or 'YYYYMMDD.HHMMSS'
;-
function mg_epoch_parse_datetime, datetime
  compile_opt strictarr
  on_error, 2

  n_datetimes = n_elements(datetime)
  if (n_datetimes gt 1L) then begin
    dts = objarr(n_datetimes)
    for d = 0L, n_datetimes - 1L do dts[d] = mg_epoch_parse_datetime(datetime[d])
    return, dts
  endif

  case 1 of
    size(datetime, /type) eq 11: return, datetime
    stregex(datetime, '[[:digit:]]{8}', /boolean): begin
        result = string(datetime, format='(%"%s.000000")')
      end
    stregex(datetime, '[[:digit:]]{8}\.[[:digit:]]{6}', /boolean): begin
        result = datetime
      end
    else: message, 'unrecognized value/format for date'
  endcase

  return, mg_datetime(result, format='%Y%m%d.%H%M%S')
end


;= API

;+
; Determine if the options are valid by the specification.
;
; :Returns:
;   1 if valid, 0 if not
;
; :Keywords:
;   error_msg : out, optional, type=string
;     set to a named variable to retrieve an error message, empty string if
;     valid
;-
function mgffepochparser::is_valid, error_msg=error_msg
  compile_opt strictarr

  self.epochs->getProperty, sections=sections

  ; every option in the epoch file should be in the specification
  for s = 0L, n_elements(sections) - 1L do begin
    options = self.epochs->options(section=sections[s], count=n_options)
    if (n_options gt 0L) then begin
      for o = 0L, n_options - 1L do begin
        spec_line = self.spec->get(options[o], section='DEFAULT', found=found)
        if (~found) then begin
          error_msg = string(options[o], $
                             format='(%"option %s not found in specification")')
          return, 0B
        endif
      endfor
    endif
  endfor

  ; every option without a default in the specification should be in the epoch
  ; file
  spec_options = self.spec->options(section='DEFAULT', count=n_options)
  for o = 0L, n_options - 1L do begin
    spec_line = self.spec->get(spec_options[o], section='DEFAULT')
    mg_parse_spec_line, spec_line, default=default
    if (n_elements(default) eq 0L) then begin
      found = 0B
      for s = 0L, n_elements(sections) - 1L do begin
        value = self.epochs->get(spec_options[o], section=sections[s], found=found)
        if (found) then break
      endfor

      if (~found) then begin
        error_msg = string(spec_options[o], $
                           format='(%"option %s not found and no default in specification")')
        return, 0
      endif
    endif
  endfor

  return, 1B
end


;+
; Retrieve a value from an epoch file.
;
; :Returns:
;   value of option (str, int, float, double, or array of those), or if
;   `datetime` is an array of 2 elements, then a `list` of values
;
; :Params:
;   option : in, required, type=string
;     name of option to lookup
;
; :Keywords:
;   datetime : in, optional, type=string/object, strarr(2)/objarr(2)
;     `mg_datetime` object or string in the form 'YYYYMMDD' or 'YYYYMMDD.HHMMSS'
;     or range of the above
;   found : out, optional, type=boolean
;     set to a named variable to retrieve whether `option` was found, if `FOUND`
;     is present, errors will not be generated
;   changed : out, optional, type=boolean
;     set to a named variable to retrieve whether the value returned for
;     `option` changed in the time interval given by `DATETIME` (only useful if
;     `DATETIME` was set to more than a single value)
;   error_message : out, optional, type=string
;     set to a named variable to retrieve the error message generated when
;     `FOUND` is false
;-
function mgffepochparser::get, option, datetime=datetime, $
                               found=found, changed=changed, $
                               error_message=error_message
  compile_opt strictarr
  on_error, 2

  n_datetimes = n_elements(datetime)
  if (n_datetimes eq 0L) then begin
    _datetime = self.datetime
    n_datetimes = 1L
  endif else begin
    _datetime = mg_epoch_parse_datetime(datetime)
  endelse

  found = 0B
  changed = 0B
  error_message = ''

  if (n_elements(obj_valid(_datetime)) ne n_datetimes) then begin
    error_message = 'no date for access given'
    if (arg_present(found)) then begin
      value = !null
      goto, done
    endif else begin
      message, error_message
    endelse
  endif

  ; look at spec to get type, default, and whether to extract
  spec_line = self.spec->get(option, section='DEFAULT', found=spec_found)
  if (~spec_found) then begin
    error_message = string(option, format='(%"no specification for ''%s'' found")')
    if (arg_present(found)) then begin
      value = !null
      goto, done
    endif else begin
      message, error_message
    endelse
  endif
  mg_parse_spec_line, spec_line, $
                      type=type, boolean=boolean, $
                      extract=extract, default=default

  ; get datetimes (sections) of epoch file and sort them chronologically
  dts = self.epochs->sections()

  if (n_elements(dts) gt 0L) then begin
    dts = dts[sort(dts)]

    if (n_datetimes gt 1L) then begin
      date_index = value_locate(dts, (_datetime[1])->strftime('%Y%m%d.%H%M%S'))
    endif else begin
      date_index = value_locate(dts, _datetime->strftime('%Y%m%d.%H%M%S'))
    endelse

    ; search for option in datetime/sections from current backwards
    for d = date_index, 0L, -1L do begin
      value = self.epochs->get(option, section=dts[d], $
                               found=found, $
                               type=type, boolean=boolean, extract=extract)
      if (found) then begin
        changed = dts[d] gt (_datetime[0])->strftime('%Y%m%d.%H%M%S')
        break
      endif
    endfor
  endif

  ; use default if not found
  if (~found) then begin
    if (n_elements(default) eq 0L) then begin
      error_message = string(option, format='(%"no value or default given for ''%s''")')
      if (arg_present(found)) then begin
        value = !null
        goto, done
      endif else begin
        message, error_message
      endelse
    endif else begin
      value = default
      found = 1B
    endelse
  endif

  done:

  ; if we created a mg_datetime object, destroy it
  if (n_elements(datetime) gt 0L) then obj_destroy, _datetime

  return, value
end


;+
; Find all the changes for a given option.
;
; :Returns:
;   array of structures with fields `datetime` and `value`
;
; :Params:
;   option_name : in, required, type=string
;     name of the option to check for changes
;-
function mgffepochparser::changes, option_name
  compile_opt strictarr

  changes = list()

  spec_line = self.spec->get(option_name, section='DEFAULT', found=spec_found)
  mg_parse_spec_line, spec_line, $
                      type=type, boolean=boolean, $
                      extract=extract, default=default

  if (n_elements(default) ne 0L) then begin
    changes->add, {datetime: 'DEFAULT', value: default}
  endif

  sections = self.epochs->sections(count=n_epochs)
  for s = 0L, n_epochs - 1L do begin
    epoch_options = self.epochs->options(section=sections[s])
    !null = where(epoch_options eq option_name, found)
    if (found) then begin
      value = self.epochs->get(option_name, section=sections[s], type=type)
      changes->add, {datetime: sections[s], value: value}
    endif
  endfor

  changes_array = changes->toArray()
  obj_destroy, changes
  return, changes_array
end


;+
; Find a filtered subset of the epochs that change the value of one of the
; given options.
;
; A new epoch object can be created from filtering an existing epoch in the
; following manner::
;
;     IDL> sub = epochs->filter(option_names)
;     IDL> new_epochs = mgffepochparser(sub, epochs.spec_filename)
;
; :Returns:
;   `MGffOptions` object
;
; :Params:
;   options : in, required, type=string/strarr
;     option or array of options to check against the epochs
;-
function mgffepochparser::filter, options
  compile_opt strictarr

  subset = mgffoptions()

  sections = self.epochs->sections(count=n_epochs)
  for s = 0L, n_epochs - 1L do begin
    epoch_options = self.epochs->options(section=sections[s])
    for o = 0L, n_elements(options) - 1L do begin
      !null = where(epoch_options eq options[o], found)
      if (found) then begin
        subset->put, options[o], $
                     self.epochs->get(options[o], $
                                      section=sections[s]), $
                     section=sections[s]
      endif
    endfor
  endfor

  return, subset
end


;= overload methods

;+
; Print help message about an `MGffEpochParser` object.
;
; :Examples:
;   For example::
;
;     IDL> help, config
;     CONFIG          MGFFEPOCHPARSER  <NEPOCHS=2  NOPTIONS=4>
;
; :Returns:
;   string
;
; :Params:
;   varname : in, required, type=string
;     `MGffOptions` object variable name
;-
function mgffepochparser::_overloadHelp, varname
  compile_opt strictarr

  !null = self.epochs->sections(count=n_epochs)
  !null = self.spec->options(section='DEFAULT', count=n_options)

  return, string(varname, obj_class(self), n_epochs, n_options, $
                 format='(%"%-15s %s  <NEPOCHS=%d  NOPTIONS=%d>")')
end


;+
; Print `MGffEpochParser` object content in an INI format that can be read by
; `MG_READ_CONFIG`.
;
; :Examples:
;   For example::
;
;     IDL> print, config
;     [Mark]
;     City:   Madison
;     State:  Wisconsin
;
;     [Mike]
;     City:   Boulder
;     State:  Colorado
;
; :Returns:
;   string
;-
function mgffepochparser::_overloadPrint
  compile_opt strictarr

  return, self.epochs->_toString()
end


;= property access

pro mgffepochparser::setProperty, datetime=datetime
  compile_opt strictarr
  on_error, 2

  if (n_elements(datetime) gt 0L) then begin
    self.datetime = mg_epoch_parse_datetime(datetime)
  endif
end


pro mgffepochparser::getProperty, datetime=datetime, $
                                  spec_filename=spec_filename
  compile_opt strictarr

  if (arg_present(datetime)) then datetime = self.datetime
  if (arg_present(spec_filename)) then spec_filename = self.spec_filename
end


;= lifecycle methods

pro mgffepochparser::cleanup
  compile_opt strictarr

  obj_destroy, [self.epochs, self.spec, self.datetime]
end


function mgffepochparser::init, epochs_filename, spec_filename
  compile_opt strictarr

  self.epochs = size(epochs_filename, /type) eq 7 $
                  ? mg_read_config(epochs_filename) $
                  : epochs_filename

  self.spec_filename = spec_filename
  self.spec          = mg_read_config(spec_filename)

  return, 1
end


pro mgffepochparser__define
  compile_opt strictarr

  define = {mgffepochparser, inherits IDL_object, $
            epochs:   obj_new(), $
            spec:     obj_new(), $
            spec_filename: '', $
            datetime: obj_new() $
           }
end

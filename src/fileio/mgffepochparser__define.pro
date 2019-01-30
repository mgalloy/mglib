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
;   value of option (str, int, float, double, or array of those)
;
; :Params:
;   option : in, required, type=string
;     name of option to lookup
;
; :Keywords:
;   datetime : in, optional, type=string/object
;     `mg_datetime` object or string in the form 'YYYYMMDD' or 'YYYYMMDD.HHMMSS'
;-
function mgffepochparser::get, option, datetime=datetime
  compile_opt strictarr
  on_error, 2

  _datetime = n_elements(datetime) gt 0L $
                ? mg_epoch_parse_datetime(datetime) $
                : self.datetime

  if (~obj_valid(_datetime)) then message, 'no date for access given'

  ; look at spec to get type, default, and whether to extract
  spec_line = self.spec->get(option, section='DEFAULT', found=spec_found)
  if (~spec_found) then begin
    message, string(option, format='(%"no specification for %s found")')
  endif
  mg_parse_spec_line, spec_line, $
                      type=type, boolean=boolean, $
                      extract=extract, default=default

  ; get datetimes (sections) of epoch file and sort them chronologically
  dts = self.epochs->sections()

  found = 0B
  if (n_elements(dts) gt 0L) then begin
    dts = dts[sort(dts)]
    date_index = value_locate(dts, _datetime->strftime('%Y%m%d.%H%M%S'))

    ; search for option in datetime/sections from current backwards
    for d = date_index, 0L, -1L do begin
      value = self.epochs->get(option, section=dts[d], $
                               found=found, $
                               type=type, boolean=boolean, extract=extract)
      if (found) then break
    endfor
  endif

  ; use default if not found
  if (~found) then begin
    if (n_elements(default) eq 0L) then begin
      message, string(option, format='(%"no value or default given for %s")')
    endif else begin
      value = default
    endelse
  endif

  ; if we created a mg_datetime object, destroy it
  if (n_elements(datetime) gt 0L && ~obj_valid(datetime)) then begin
    obj_destroy, _datetime
  endif

  return, value
end


;= property access

pro mgffepochparser::setProperty, datetime=datetime
  compile_opt strictarr
  on_error, 2

  if (n_elements(datetime) gt 0L) then begin
    self.datetime = mg_epoch_parse_datetime(datetime)
  endif
end


pro mgffepochparser::getProperty, datetime=datetime
  compile_opt strictarr

  if (arg_present(datetime)) then datetime = self.datetime
end


;= lifecycle methods

pro mgffepochparser::cleanup
  compile_opt strictarr

  obj_destroy, [self.epochs, self.spec, self.datetime]
end


function mgffepochparser::init, epochs_filename, spec_filename
  compile_opt strictarr

  self.epochs = mg_read_config(epochs_filename)
  self.spec   = mg_read_config(spec_filename)

  return, 1
end


pro mgffepochparser__define
  compile_opt strictarr

  define = {mgffepochparser, inherits IDL_object, $
            epochs:   obj_new(), $
            spec:     obj_new(), $
            datetime: obj_new() $
           }
end

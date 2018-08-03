; docformat = 'rst'

;= helper routines

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
    else: message, 'unrecognized format for date'
  endcase

  return, mg_datetime(result, format='%Y%m%d.%H%M%S')
end


;= API

function mgffepochparser::is_valid
  compile_opt strictarr

  ; TODO: implement
  return, 1B
end


function mgffepochparser::get, option, datetime=datetime
  compile_opt strictarr
  on_error, 2

  _datetime = n_elements(datetime) gt 0L $
                ? mg_epoch_parse_datetime(datetime) $
                : self.datetime

  if (~obj_valid(_datetime)) then message, 'no date for access given'


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

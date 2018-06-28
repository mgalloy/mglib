; docformat = 'rst'

;= API

function mg_date::strftime, format
  compile_opt strictarr

  return, mg_strftime(self.jd, format)
end


;= overload methods

function mg_date::_overloadHelp, varname
  compile_opt strictarr

  ; date_fmt = '%a %b %d %H:%M:%S %Y'
  date_fmt = '", C(), %"'

  fmt = string(date_fmt, format='(%"%%-15s %%s  <%s>")')

  return, string(varname, obj_class(self), self.jd, format=fmt)
end


;= property access

pro mg_date::setProperty, date=date, epoch=epoch
  compile_opt strictarr

  if (size(date, /type) eq 7) then begin
    self.jd = mg_strptime(date)
  endif else begin
    self.jd = keyword_set(epoch) ? mg_epoch2julian(date) : date
  endelse

end


pro mg_date::getProperty, year=year, month=month, day=day, doy=doy, $
                          hour=hour, minute=minute, second=second
  compile_opt strictarr

  caldat, self.jd, month, day, year, hour, minute, second
end


;= lifecycle

pro mg_date::cleanup
  compile_opt strictarr

  ; nothing to cleanup
end


function mg_date::init, date
  compile_opt strictarr

  if (n_elements(date) gt 0L) then begin
    self.setProperty, date=date
  endif else begin
    self.setProperty, date=systime(/julian)
  endelse

  return, 1
end


pro mg_date__define
  compile_opt strictarr

  define = {mg_date, inherits IDL_Object, $
            jd : 0.0D $
           }
end

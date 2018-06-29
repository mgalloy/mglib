; docformat = 'rst'

;= static methods

function mg_datetime::strptime, date, format
  compile_opt strictarr, static

  return, mg_datetime(mg_strptime(date, format))
end


;= helper methods

function mg_datetime::to_struct
  compile_opt strictarr

  return, {year: self.year, month: self.month, day: self.day, $
           hour: self.hour, minute: self.minute, second: self.second}
end


function mg_datetime::to_julian
  compile_opt strictarr

  return, julday(self.month, self.day, self.year, self.hour, self.minute, self.second)
end


;= API

function mg_datetime::strftime, format
  compile_opt strictarr

  return, mg_strftime(self->to_struct(), format)
end


;= overload methods

function mg_datetime::_overloadMinus, dt1, dt2
  compile_opt strictarr

  if (obj_isa(dt2, 'mg_datetime')) then begin
    return, mg_timedelta(days=dt1->to_julian() - dt2->to_julian())
  endif else if (obj_isa(dt2, 'mg_timedelta')) then begin
    return, mg_datetime(dt1->to_julian() - dt2->to_days())
  endif
end


function mg_datetime::_overloadPlus, dt1, dt2
  compile_opt strictarr
  on_error, 2

  if (obj_isa(dt2, 'mg_datetime')) then begin
    message, 'cannot add two date/times'
  endif else if (obj_isa(dt2, 'mg_timedelta')) then begin
    return, mg_datetime(dt1->to_julian() + dt2->to_days())
  endif
end


function mg_datetime::_overloadPrint
  compile_opt strictarr

  return, mg_strftime(self->to_struct(), '%a %b %d %H:%M:%S %Y')
end


function mg_datetime::_overloadHelp, varname
  compile_opt strictarr

  return, string(varname, $
                 obj_class(self), $
                 mg_strftime(self->to_struct(), '%a %b %d %H:%M:%S %Y'), $
                 format='(%"%-15s %s  <%s>")')
end


;= property access

pro mg_datetime::setProperty, date=date, epoch=epoch, format=format
  compile_opt strictarr

  type = size(date, /type)
  if (type eq 7) then begin
    self->setProperty, date=mg_strptime(date, format)
  endif else if (type eq 8) then begin
    self.year   = date.year
    self.month  = date.month
    self.day    = date.day
    self.hour   = date.hour
    self.minute = date.minute
    self.second = date.second
  endif else begin
    caldat, date, month, day, year, hour, minute, second
    self.year   = year
    self.month  = month
    self.day    = day
    self.hour   = hour
    self.minute = minute
    self.second = second
  endelse

end


pro mg_datetime::getProperty, year=year, $
                          month=month, mname=month_name, $
                          day=day, doy=doy, $
                          hour=hour, minute=minute, second=second
  compile_opt strictarr

  if (arg_present(year)) then year = self.year
  if (arg_present(month)) then month = self.month
  if (arg_present(day)) then day = self.day
  if (arg_present(hour)) then hour = self.hour
  if (arg_present(minute)) then minute = self.minute
  if (arg_present(second)) then second = self.second

  if (arg_present(doy)) then begin
    doy = mg_ymd2doy(self.year, self.month, self.day)
  endif

  if (arg_present(month_name)) then begin
    jd = julday(self.month, self.day, self.year, self.hour, self.minute, self.second)
    month_name = string(jd, format='(C(CMoA))')
  endif
end


;= lifecycle

pro mg_datetime::cleanup
  compile_opt strictarr

  ; nothing to cleanup
end


function mg_datetime::init, date, _extra=e
  compile_opt strictarr

  if (n_elements(date) gt 0L) then begin
    self.setProperty, date=date, _extra=e
  endif else begin
    self.setProperty, date=systime(/julian)
  endelse

  return, 1
end


pro mg_datetime__define
  compile_opt strictarr

  define = {mg_datetime, inherits IDL_Object, $
            year   : 0L, $
            month  : 0L, $
            day    : 0L, $
            hour   : 0L, $
            minute : 0L, $
            second : 0.0D $
           }
end

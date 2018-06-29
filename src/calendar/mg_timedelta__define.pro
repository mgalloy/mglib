; docformat = 'rst'

;= helper methods

pro mg_timedelta::_convert_types, days=days, hours=hours, minutes=minutes, seconds=seconds
  compile_opt strictarr

  days    = mg_default(days, 0L)
  hours   = mg_default(hours, 0L)
  minutes = mg_default(minutes, 0L)
  seconds = mg_default(seconds, 0.0D)

  hours += 24L * (days - long(days))
  days = long(days)

  minutes += 60L * (hours - long(hours))
  hours = long(hours)

  seconds += 60.0D * (minutes - long(minutes))
  minutes = long(minutes)

  seconds = double(seconds)
end


;= output

function mg_timedelta::to_seconds
  compile_opt strictarr

  return, self.seconds + 60.0D * (self.minutes + 60.0D * (self.hours + 24.0D * self.days))
end


function mg_timedelta::to_days
  compile_opt strictarr

  return, self.days + (self.hours + (self.minutes + self.seconds / 60.0D) / 60.0) / 24.0D
end


function mg_timedelta::to_string
  compile_opt strictarr

  n_components = 4L
  results = strarr(n_components)
  good    = bytarr(n_components)
  values  = [self.days, self.hours, self.minutes]
  names   = ['day', 'hour', 'minute']

  for v = 0L, n_elements(values) - 1L do begin
    if (values[v] gt 0L) then begin
      results[v] = string(values[v], names[v], values[v] gt 1L ? 's' : '', $
                          format='(%"%d %s%s")')
      good[v] = 1B
    endif
  endfor

  results[3] = string(self.seconds, format='(%"%0.1f seconds")')
  good[3] = 1B

  return, strjoin(results[where(good)], ', ')
end


;= overload methods

function mg_timedelta::_overloadMinus, arg1, arg2
  compile_opt strictarr

  return, mg_timedelta(seconds=arg1->to_seconds() - arg2->to_seconds())
end


function mg_timedelta::_overloadPlus, arg1, arg2
  compile_opt strictarr
  on_error, 2

  if (obj_isa(arg2, 'mg_timedelta')) then begin
    return, mg_timedelta(seconds=arg1->to_seconds() + arg2->to_seconds())
  endif else if (obj_isa(arg2, 'mg_datetime')) then begin
    return, arg2 + arg1    ; delegate to mg_datetime::_overloadPlus
  endif else message, 'unknown addition argument type'
end


function mg_timedelta::_overloadAsterisk, arg1, arg2
  compile_opt strictarr
  ;on_error, 2

  if (obj_valid(arg1) && obj_valid(arg2)) then message, 'cannot multiple two objects'

  if (obj_valid(arg1) && obj_isa(arg1, 'mg_timedelta')) then begin
    return, mg_timedelta(seconds=arg2 * arg1->to_seconds())
  endif

  if (obj_valid(arg2) && obj_isa(arg2, 'mg_timedelta')) then begin
    return, mg_timedelta(seconds=arg1 * arg2->to_seconds())
  endif
end


function mg_timedelta::_overloadPrint
  compile_opt strictarr

  return, self->to_string()
end


function mg_timedelta::_overloadHelp, varname
  compile_opt strictarr

  return, string(varname, $
                 obj_class(self), $
                 self->to_string(), $
                 format='(%"%-15s %s  <%s>")')
end


;= property access

pro mg_timedelta::setProperty, days=days, hours=hours, minutes=minutes, seconds=seconds
  compile_opt strictarr

  _days    = mg_default(days, 0L)
  _hours   = mg_default(hours, 0L)
  _minutes = mg_default(minutes, 0L)
  _seconds = mg_default(seconds, 0.0D)
  self->_convert_types, days=_days, hours=_hours, minutes=_minutes, seconds=_seconds
  self.days    = _days
  self.hours   = _hours
  self.minutes = _minutes
  self.seconds = _seconds

  if (self.seconds ge 60.0) then begin
    self.minutes += long(self.seconds / 60.0D)
    self.seconds mod= 60.0D
  endif

  if (self.minutes ge 60) then begin
    self.hours += self.minutes / 60L
    self.minutes mod= 60L
  endif

  if (self.hours ge 24) then begin
    self.days += self.hours / 24L
    self.hours mod= 24L
  endif
end


pro mg_timedelta::getProperty, days=days, hours=hours, minutes=minutes, seconds=seconds
  compile_opt strictarr

  if (arg_present(days)) then days = self.days
  if (arg_present(hours)) then hours = self.hours
  if (arg_present(minutes)) then minutes = self.minutes
  if (arg_present(seconds)) then seconds = self.seconds
end


;= lifecycle methods

function mg_timedelta::init, _extra=e
  compile_opt strictarr

  self->setProperty, _extra=e
  return, 1
end


pro mg_timedelta__define
  compile_opt strictarr

  define = {mg_timedelta, inherits IDL_Object, $
            days    : 0L, $
            hours   : 0L, $
            minutes : 0L, $
            seconds : 0.0D}
end


; main-level example program

d1 = mg_datetime.strptime('2018-02-17 17:45:05', '%Y-%m-%d %H:%M:%S')
d2 = mg_datetime.strptime('2018-06-28 12:15:37', '%Y-%m-%d %H:%M:%S')

diff = d2 - d1
help, diff
print, diff

d3 = d2 + diff
help, d3
print, d3

d4 = d2 + 2 * diff
help, d4
print, d4

end

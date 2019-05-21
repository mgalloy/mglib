; docformat = 'rst'

;+
; Convenience class for using `MG_FLOAT2STR` as a `[XYZ]TICKFORMAT` value in a
; direct graphics plot.
;
; :Todo:
;   handle calendar
;
; :Properties:
;   places_sep : type=string
;     separator to use in between groups of 3 places left of the decimal point
;     when not using exponential form; default is the empty string
;   decimal_sep : type=string
;     decimal point separator; default is '.'
;   n_places : type=integer
;     cutoff number of digits to the left of the decimal point before switching
;     to the exponential form; defaults to 0 for integers, 7 for floats, or 15
;     for doubles
;   n_digits : type=integer
;     number of positions after the decimal point in the standard form or the
;     number of significant digits in the exponential form; defaults to 0 for
;     integers, 7 for floats, or 15 for doubles
;-


;= IDL_Object overload methods

;+
; Format a float value into a string.
;
; :Returns:
;   string
;-
function mg_tickformat::_overloadFunction, axis, index, value, level
  compile_opt strictarr

  if (self.calendar_format eq '') then begin
    return, mg_float2str(value, $
                         places_sep=self.places_sep, $
                         decimal_sep=self.decimal_sep, $
                         n_places=self.n_places, $
                         n_digits=self.n_digits)
  endif else begin
    return, string(value, format='(' + self.calendar_format + ')')
  endelse
end


;= property access

;+
; Set properties.
;-
pro mg_tickformat::setProperty, places_sep=places_sep, $
                                decimal_sep=decimal_sep, $
                                n_places=n_places, $
                                n_digits=n_digits
  compile_opt strictarr

  if (n_elements(places_sep) gt 0L) then self.places_sep = places_sep
  if (n_elements(decimal_sep) gt 0L) then self.decimal_sep = decimal_sep
  if (n_elements(n_places) gt 0L) then self.n_places = n_places
  if (n_elements(n_digits) gt 0L) then self.n_digits = n_digits
end


;= lifecycle

;+
; Create a tick format object.
;
; :Returns:
;   1 if successful, 0 for failure
;
; :Keywords:
;   calendar_format : in, optional, type=boolean/string
;     set to indicate to use default calendar time formatting, set to a format
;     string to specify a specific format
;   _extra : in, optional, type=keywords
;     keywords accepted by `setProperty`
;-
function mg_tickformat::init, calendar_format=calendar_format, _extra=e
  compile_opt strictarr

  if (size(calendar_format, /type) eq 7) then begin
    case 1 of
      strlowcase(calendar_format) eq 'seconds': self.calendar_format = 'C(CHI2.2, ":", CMI2.2, ":", CSI2.2)'
      strlowcase(calendar_format) eq 'minutes': self.calendar_format = 'C(CHI2.2, ":", CMI2.2)'
      strlowcase(calendar_format) eq 'hours': self.calendar_format = 'C(CHI2.2)'
      strlowcase(calendar_format) eq 'days': self.calendar_format = 'C(CYI4, "-", CMoI2.2, "-", CDI2.2)'
      strlowcase(calendar_format) eq 'months': self.calendar_format = 'C(CYI4, "-", CMoI2.2)'
      strlowcase(calendar_format) eq 'years': self.calendar_format = 'C(CYI4)'
      else: self.calendar_format = calendar_format
    endcase
  endif else begin
    if (keyword_set(calendar_format)) then begin
      self.calendar_format = 'C(CDwA, X, CMoA, X, CDI2.2, X, CHI2.2, ":", CMI2.2, ":", CSI2.2, CYI5)'
    endif
  endelse

  self.places_sep = ''
  self.decimal_sep = '.'
  self.n_places = 0L
  self.n_digits = 0L

  self->setProperty, _extra=e

  return, 1
end


;+
; Define `MG_TickFormat` class.
;-
pro mg_tickformat__define
  compile_opt strictarr

  !null = {mg_tickformat, inherits idl_object, $
           calendar_format: '', $
           places_sep: '', $
           decimal_sep: '', $
           n_places: 0L, $
           n_digits: 0L}
end


; main-level example program

my_xformat = mg_tickformat(places_sep=',', n_places=4, n_digits=2)
my_yformat = mg_tickformat(places_sep='.', decimal_sep=',', n_places=4, n_digits=1)
plot, findgen(10000), /nodata, $
      xtitle='English format', xtickformat='my_xformat', $
      ytitle='Non-English European format', ytickformat='my_yformat'

window, /free
data_format = mg_tickformat(places_sep=',', n_digits=1)
time_format = mg_tickformat(calendar='minutes')
times = timegen(24, units='Hours', step_size=1, start=systime(/julian))
plot, times, 100 * findgen(24), $
      xtitle='Time', xtickformat='time_format', $
      ytitle='Value', ytickformat='data_format'
end

; docformat = 'rst'

;+
; Convenience class for using `MG_FLOAT2STR` as a `[XYZ]TICKFORMAT` value in a
; direct graphics plot.
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

  return, mg_float2str(value, $
                       places_sep=self.places_sep, $
                       decimal_sep=self.decimal_sep, $
                       n_places=self.n_places, $
                       n_digits=self.n_digits)
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
;   _extra : in, optional, type=keywords
;     keywords accepted by `setProperty`
;-
function mg_tickformat::init, _extra=e
  compile_opt strictarr

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

end

; docformat = 'rst'

;+
; Convert a float/double to a string.
;
; :Examples:
;   Try::
;
;     IDL> help, mg_float2str(123456.1234, n_places=5, n_digits=3)
;     <Expression>    STRING    = '1.23e+05'
;     IDL> help, mg_float2str(12345.1234, n_places=5, n_digits=3) 
;     <Expression>    STRING    = '12345.123'
;
; :Returns:
;   string
;
; :Params:
;   f : in, required, type=float/double
;     float or double to convert
;
; :Keywords:
;   n_places : in, optional, type=integer, default="0, 7, or 15"
;     cutoff number of digits to the left of the decimal point before switching
;     to the exponential form; defaults to 0 for integers, 7 for floats, or 15
;     for doubles
;   n_digits : in, optional, type=integer, default="0, 7 or 15"
;     number of positions after the decimal point in the standard form or the
;     number of significant digits in the exponential form; defaults to 0 for
;     integers, 7 for floats, or 15 for doubles
;-
function mg_float2str, f, n_places=n_places, n_digits=n_digits
  compile_opt strictarr
  on_error, 2

  type = size(f, /type)
  switch type of
    1:
    2:
    3:
    12:
    13:
    14:
    15: begin
        default_width = 0L
        break
      end
    4: begin
        default_width = 7L
        break
      end
    5: begin
        default_width = 15L
        break
      end
    else: message, 'invalid argument type'
  endswitch

  _n_places = n_elements(n_places) eq 0L ? default_width : n_places
  _n_digits = n_elements(n_digits) eq 0L ? default_width : n_digits

  n_places_present = long(alog10(abs(f))) + 1L
  if (n_places_present gt _n_places) then begin
    format = string(_n_digits, format='(%"(\%\"\%0.%dg\")")')
  endif else begin
    format = string(_n_digits, format='(%"(\%\"\%0.%df\")")')
  endelse

  return, string(f, format=format)
end

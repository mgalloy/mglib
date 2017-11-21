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
;   places_sep : in, optional, type=string, default=''
;     separator to use in between groups of 3 places left of the decimal point
;     when not using exponential form
;   decimal_sep : in, optional, type=string, default='.'
;     decimal point separator
;-
function mg_float2str, f, $
                       n_places=n_places, n_digits=n_digits, $
                       places_sep=places_sep, decimal_sep=decimal_sep
  compile_opt strictarr
  on_error, 2

  if (n_elements(f) gt 1L) then begin
    result = strarr(n_elements(f))
    for i = 0L, n_elements(f) - 1L do begin
      result[i] = mg_float2str(f[i], $
                               n_places=nplaces, $
                               n_digits=n_digits, $
                               places_sep=places_sep, $
                               decimal_sep=decimal_sep)
    endfor
    return, result
  endif

  _places_sep = n_elements(places_sep) eq 0L ? '' : places_sep
  _decimal_sep = n_elements(decimal_sep) eq 0L ? '.' : decimal_sep

  type = size(f, /type)
  integer_type = 0B
  switch type of
    1:
    2:
    3:
    12:
    13:
    14:
    15: begin
        default_width = 0L
        integer_type = 1B
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
  if (n_places_present gt _n_places && _n_places gt 0L) then begin
    format = string(_n_digits, format='(%"(\%\"\%0.%de\")")')
    s = string(f, format=format)
    tokens = strsplit(s, '.', /extract)
    return, strjoin(tokens, _decimal_sep)
  endif

  if (integer_type) then begin
    format = '(%"%d")'
  endif else begin
    format = string(_n_digits, format='(%"(\%\"\%0.%df\")")')
  endelse

  s = string(f, format=format)
  if (_places_sep eq '') then return, s

  tokens = strsplit(s, '.', /extract)

  places = string(reverse(byte(tokens[0])))
  if (strlen(places) le 3) then begin
    tokens = strsplit(s, '.', /extract)
    return, strjoin(tokens, _decimal_sep)
  endif

  b = bytarr(3 * ceil(strlen(places) / 3.0)) + (byte(' '))[0]
  b[0] = byte(places)
  psep = byte(strarr(n_elements(b) / 3) + _places_sep)
  b = reform(b, 3, n_elements(b) / 3)
  b = [b, psep]
  places = reform(b, n_elements(b))
  places[-1] = (byte(' '))[0]
  tokens[0] = strtrim(reverse(places), 2)

  return, strjoin(tokens, _decimal_sep)
end

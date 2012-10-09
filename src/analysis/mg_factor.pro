; docformat = 'rst'

;+
; Returns the prime factorization of a given integer value `n`. If the input
; is prime, returns the value itself.
;
; :Examples:
;    The following are factorizations of values::
;
;       IDL> print, mg_factor(2*27*5)
;              2       3       3       3       5
;       IDL> print, mg_factor(13)
;             13
;
; :Returns:
;    integer array of factors, the same type as the input `n`
;
; :Params:
;    n : in, required, type=integer type
;       value to factor
;-
function mg_factor, n
  compile_opt strictarr
  on_error, 2

  if (n_elements(n) eq 0) then message, 'incorrect number of arguments'
  if (~mg_isinteger(n)) then message, 'integer arguments required'

  factors = [-1]
  _n = n
  f = n - n + 2B
  while (f le sqrt(_n)) do begin
    while (_n mod f eq 0) do begin
      factors = [factors, f]
      _n /= f
    endwhile
    f++
  endwhile
  if (_n gt 1) then factors = [factors, _n]

  return, n_elements(factors) eq 1L ? factors[0] : factors[1:*]
end

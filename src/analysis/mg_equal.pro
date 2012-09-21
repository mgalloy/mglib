; docformat = 'rst'

;+
; Determines whether two values are equal, or within a given tolerance.
;
; :Returns:
;    1 if the two values are within the tolerance, 0 if not; for array values
;    calculates the Euclidean distance between the two arrays or array and 
;    scalar
; 
; :Params:
;    a : in, required, type=numeric scalar/array
;       first value(s) to compare
;    b : in, required, type=numeric scalar/array
;       second value(s) to compare
;
; :Keywords:
;    tolerance : in, optional, type=numeric, default=machine precision
;       tolerance within which the two values are considered equal
;-
function mg_equal, a, b, tolerance=tolerance
  compile_opt strictarr
  
  double = size(a, /type) eq 5L || size(b, /type) eq 5L
  info = machar(double=double)
  
  _tolerance = n_elements(tolerance) eq 0L ? info.eps : tolerance
  
  diff = (abs(a - b)) ^ 2
  if (n_elements(diff) gt 0L) then diff = total(diff)
  diff = sqrt(diff)
  
  return, diff lt _tolerance
end

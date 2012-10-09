; docformat = 'rst'

;+
; Create an array ranging from the `startValue` and stopping before the
; `stopValue`.
;
; :Examples:
;    See the examples in the main-level program at the end of this file::
;
;       IDL> print, mg_makerange(0, 10)
;             0.0000000      1.0000000      2.0000000      3.0000000
;             4.0000000      5.0000000      6.0000000      7.0000000
;             8.0000000      9.0000000     10.0000000
;       IDL> print, mg_makerange(0, 10, n=5)
;             0.0000000      2.5000000      5.0000000      7.5000000
;            10.0000000
;       IDL> print, mg_makerange(0, 10, increment=0.5)
;             0.0000000      0.5000000      1.0000000      1.5000000
;             2.0000000      2.5000000      3.0000000      3.5000000
;             4.0000000      4.5000000      5.0000000      5.5000000
;             6.0000000      6.5000000      7.0000000      7.5000000
;             8.0000000      8.5000000      9.0000000      9.5000000
;            10.0000000
;
; :Returns:
;    `fltarr`
;
; :Params:
;    startValue : in, required, type=float
;       first value of the output array
;    stopValue : in, required, type=float
;       largest possible value for the last value of the output array
;
; :Keywords:
;    n : in, optional, type=long
;       number of elements in the output array; if not set, it is calculated
;       from `INCREMENT`
;    count : out, optional, type=long
;       set to a named variable to return the number of elements in the
;       returned array, i.e., `N` if `N` is used
;    increment : in, optional, type=float, default=1.0
;       if `N` is not set, then `INCREMENT` is used to compute `N`
;-
function mg_makerange, startValue, stopValue, increment=increment, n=n, $
                       count=count
  compile_opt strictarr

  _increment = n_elements(increment) gt 0L ? increment : 1.0

  if (n_elements(n) gt 0L) then begin
    count = long(n)
    return, startValue + findgen(n) / (n - 1L) * (stopValue - startValue)
  endif else begin
    count = long((stopValue - startValue) / _increment + 1L)
    return, startValue + findgen(count) * _increment
  endelse
end


; main-level examples

print, mg_makerange(0, 10)
print, mg_makerange(0, 10, n=5)
print, mg_makerange(0, 10, increment=0.5)
print, mg_makerange(0., 10., increment=0.1, count=count)

end

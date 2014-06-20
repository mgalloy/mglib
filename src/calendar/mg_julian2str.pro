; docformat = 'rst'

;+
; Convert a Julian date/time to a string representation. The `SHORT` keyword``
; creates a date/time of the form `201103010224` for March 1, 2011 02:24 am.
;
; :Returns:
;   string
;
; :Params:
;   day : in, required, type=double
;     Julian date/time
;
; :Keywords:
;   short : in, optional, type=boolean
;     set to give the "short" representation of the Julian date/time
;-
function mg_julian2str, day, short=short
  compile_opt strictarr

  if (keyword_set(short)) then begin
    f = '(C(CYI04, CMOI02, CDI02, CHI02, CMI02))'
  endif else begin
    f = '(C(CDwA, X, CMoA, X, CDI2.2, X, CHI2.2, ":", CMI2.2, ":", CSI2.2, CYI5))'
  endelse

  return, string(day, format=f)
end
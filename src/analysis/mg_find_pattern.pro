; docformat = 'rst'

;+
; Finds a 1-dimensional pattern in an array.
;
; :Examples:
;    For example, try the main-level program at the end of this file::
;
;       IDL> .run mg_find_pattern
;
;    It finds a simple pattern in random integers::
;
;       IDL> d = long(randomu(0L, 32) * 100L)
;       IDL> print, d
;                 41           9          75          52          93
;                 38          65           6          72          67
;                 38          63          88          51          65
;                 23          26          76          75          90
;                  7          27          89          27          51
;                 35          24          48          84          83
;                  3          99
;       IDL> print, mg_find_pattern(d, [63, 88, 51])
;                 11
;       IDL> print, d[11:13]
;                 63          88          51
;
; :Returns:
;    index array or `!null` if pattern not found
;
; :Params:
;    data : in, required, type=array
;       array to search for pattern
;    pattern : in, required, type=array
;       pattern to find in the data
;
; :History:
;   Developed from code posted by JD Smith to the IDL newsgroup 8/16/2011
;
; :Requires:
;   IDL 8.0
;-
function mg_find_pattern, data, pattern
  compile_opt strictarr

  n = n_elements(data)
  w = where(data eq pattern[(c = 0L)], /null)
  while ((n_elements(w) gt 0L) && (++c lt n_elements(pattern))) do begin
    keep = where(data[w + c < n] eq pattern[c], /null)
    w = w[keep]
  endwhile

  return, w
end


; main-level example program

d = long(randomu(0L, 32) * 100L)
print, d
print, mg_find_pattern(d, [63, 88, 51])
print, d[11:13]

end

; docformat = 'rst'

;+
; Convert a floating point number of degrees to integer degrees, minutes, and
; seconds.
;
; :Returns:
;   `lonarr(3)`
;
; :Params:
;   degrees : in, required, type=float
;     number of degrees
;-
function mg_deg2dms, degrees
  compile_opt strictarr

  d = floor(degrees)
  dec_m = 60L * (degrees - d)
  m = floor(dec_m)
  s = round(60L * (dec_m - m))

  return, [d, m, s]
end

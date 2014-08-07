; docformat = 'rst'

;+
; Convert Julian dates to epoch times.
;
; :Returns:
;   double or `dblarr`
;
; :Params:
;   jdates : in, required, type=double/dblarr
;     scalar or array of Julian dates
;-
function mg_julian2epoch, jdates
  compile_opt strictarr

  return, (jdates - julday(1, 1, 1970, 0, 0, 0)) * (24.0D * 60.0D * 60.0D)
end

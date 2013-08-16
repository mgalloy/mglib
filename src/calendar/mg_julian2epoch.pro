; docformat = 'rst'

;+
; Convert Julian dates to epoch times.
;
; :Returns:
;   `fltarr`
;
; :Params:
;   jdates : in, required, type=fltarr
;     scalar or array of Julian dates
;-
function mg_julian2epoch, jdates
  compile_opt strictarr

  return, (jdates - julday(1, 1, 1970, 0, 0, 0)) * (24. * 60. * 60.)
end

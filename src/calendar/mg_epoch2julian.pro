; docformat = 'rst'

;+
; Convert epoch times to Julian times.
;
; :Returns:
;   `fltarr`
;
; :Params:
;   times : in, required, type=fltarr
;     scalar or array of epoch times
;-
function mg_epoch2julian, times
  compile_opt strictarr

  return, julday(1, 1, 1970, 0, 0, 0) + times / (24.0D * 60.0D * 60.0D)
end

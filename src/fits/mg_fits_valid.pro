; docformat = 'rst'

;+
; Test an FCB returned from `FITS_OPEN` to make sure it is valid.
;
; :Returns:
;   byte; 1 is valid, 0 if not

; :Params:
;   fcb : in, required, type=long or structure
;     FCB as returned from `FITS_OPEN`
;-
function mg_fits_valid, fcb
  compile_opt strictarr

  return, size(fcb, /type) eq 8
end

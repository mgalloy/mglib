; docformat = 'rst'

;+
; Test a filename of a FITS file or FCB returned from `FITS_OPEN` to make sure
; it is valid.
;
; :Returns:
;   byte; 1 is valid, 0 if not
;
; :Params:
;   f : in, required, type=long/structure/string
;     filename of FITS file or FCB as returned from `FITS_OPEN`
;-
function mg_fits_valid, f
  compile_opt strictarr

  case size(f, /type) of
    7: begin
        if (~file_test(f)) then is_valid = 0 else begin
          fits_open, f, fcb
          is_valid = size(fcb, /type) eq 8
          fits_close, fcb
        endelse
      end
    8: is_valid = size(f, /type) eq 8
    else: is_valid = 0B
  endcase

  return, is_valid
end

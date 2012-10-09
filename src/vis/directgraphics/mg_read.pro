; docformat = 'rst'

;+
; Reads from the current graphics device (WIN, X, or Z devices) and returns
; the image in the TRUE format specified.
;
; NOTE: on Mac OS X, the resize indicator in the lower right of the image is
; filled with a solid color using the pixel immediately to the left of the
; indicator at y=0.
;
; :Examples:
;    See the main-level program at the end of this file::
;
;       IDL> .run mg_read
;
; :Returns:
;    image byte array
;
; :Params:
;    xstart : in, optional, type=long, default=0L
;       starting column to read
;    ystart : in, optional, type=long, default=0L
;       starting row to read
;    nx : in, optional, type=long, default=fill window from xstart
;       number of columns to read
;    ny : in, optional, type=long, default=fill window from ystart
;       number of rows to read
;    channel : in, optional, type=long, default=0L
;       the memory channel to read
;
; :Keywords:
;    true : in, optional, type=long
;       TRUE format of output image desired; defaults to 0 on 8-bit hardware
;       and 1 on higher bit-depths
;    red : out, optional, type=bytarr
;       red values for the color table produced if TRUE was set to 0 on a
;       graphics device supporting 24-bit color
;    green : out, optional, type=bytarr
;       green values for the color table produced if TRUE was set to 0 on a
;       graphics device supporting 24-bit color
;    blue : out, optional, type=bytarr
;       blue values for the color table produced if TRUE was set to 0 on a
;       graphics device supporting 24-bit color
;    _extra : in, optional, type=keywords
;       keywords to TVRD
;-
function mg_read, xstart, ystart, nx, ny, channel, true=true, $
                  red=red, green=green, blue=blue, _extra=e
  compile_opt strictarr
  on_error, 2

  ; make sure we have a valid graphics device
  if (!d.name ne 'WIN' && !d.name ne 'X' && !d.name ne 'Z') then begin
    message, 'unable to read from current device: ' + !d.name
  endif

  ; can't read from non-existent windows
  if (!d.name ne 'Z' && !d.window eq -1L) then begin
    message, 'no open graphics windows'
  endif

  ; get the visual depth based on the graphics device
  if (!d.name eq 'Z') then begin
    device, get_pixel_depth=depth
  endif else begin
    device, get_visual_depth=depth
  endelse

  ; set default values
  _xstart = n_elements(xstart) gt 0L ? xstart : 0L
  _ystart = n_elements(ystart) gt 0L ? ystart : 0L
  _nx = n_elements(nx) gt 0L ? nx : !d.x_size - _xstart
  _ny = n_elements(ny) gt 0L ? ny : !d.y_size - _ystart
  _channel = n_elements(channel) gt 0L ? channel : 0L

  ; this is the TRUE value that the user wants...
  _desiredTrue = n_elements(true) gt 0L ? true : (depth gt 8 ? 1L : 0L)

  ; ...but TRUE must be set to match the visual depth when doing the read (the
  ; output will be converted later if this does not match the user's desire)
  if (n_elements(true) gt 0L) then begin
    if (depth le 8L) then begin
      _neededTrue = 0L
    endif else begin
      _neededTrue = (true gt 0L) ? true : 1L
    endelse
  endif else begin
    _neededTrue = depth gt 8 ? 1L : 0L
  endelse

  ; remember decomppsed state
  device, get_decomposed=decomposed

  ; must be in decomposed color if device supports it
  if (depth gt 8L) then device, decomposed=1L

  ; read from the graphics device
  im = tvrd(_xstart, _ystart, _nx, _ny, _channel, true=_neededTrue, _extra=e)

  ; place back original decomposed state
  device, decomposed=decomposed

  ; convert the image if it is not in the user's desired TRUE format
  if (_neededTrue ne _desiredTrue) then begin
    im = mg_maketrue(im, true=_desiredTrue, input_true=_neededTrue, $
                     red=red, green=green, blue=blue)
  endif

  ; fix lower right corner if on a Mac
  if (!version.os eq 'darwin' && !d.name eq 'X') then begin
    ; Mac OS X puts a 15 x 15 pixel resizing indicator in the lower right of
    ; it's graphics windows
    dims = mg_image_getsize(im)
    if (total(dims gt 15) ge 2) then begin
      case _desiredTrue of
        0: im[dims[0] - 15:dims[0] - 1, 0:14] = im[dims[0] - 16, 0]
        1: im[*, dims[0] - 15:dims[0] - 1, 0:14] $
             = rebin(reform(im[*, dims[0] - 16, 0], 3, 1, 1), 3, 15, 15)
        2: im[dims[0] - 15:dims[0] - 1, *, 0:14] $
             = rebin(reform(im[dims[0] - 16, *, 0], 1, 3, 1), 15, 3, 15)
        3: im[dims[0] - 15:dims[0] - 1, 0:14, *] $
             = rebin(reform(im[dims[0] - 16, 0, *], 1, 3, 1), 15, 15, 3)
      endcase
    endif
  endif

  return, im
end


; main-level example program

mg_decomposed, 1, old_decomposed=dec

mg_window, xsize=4, ysize=3, /inches, /free, title='Original image'
plot, findgen(11), color='000030'x, background='ffffff'x
imTrue = mg_read(true=1)
imIndexed = mg_read(true=0, red=r, green=g, blue=b)

mg_window, xsize=8, ysize=3, /inches, /free, $
           title='TrueColor image - indexed color image'
tv, imTrue, 0, true=1
mg_decomposed, 0
tvlct, r, g, b
tv, imIndexed, 1

mg_decomposed, dec

end

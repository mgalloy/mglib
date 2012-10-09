; docformat = 'rst'

;+
; Return the x and y size of the given image array.
;-

;+
; Returns the size of the image array as a two element array, [xsize, ysize].
; The TRUE keyword can be set to indicate the interleave or it can be guessed
; if the TRUE keyword is not present.
;
; :Returns:
;    lonarr(2)
;
; :Params:
;    im : in, required, type=image array
;       image array of the form (m, n), (3, m, n), (m, 3, n), or (m, n, 3)
;
; :Keywords:
;    true : in, out, optional, type=long
;       Set to 0 for (m, n) array images, 1 for (3, m, n),  2 for (m, 3, n),
;       and 3 for (m, n, 3).
;
;       If TRUE is not present, `MG_IMAGE_GETSIZE` will attempt to guess the
;       size. 2D images will automatically be set to TRUE=0; 3D images'
;       dimensions will be searched for a size 3 dimension.
;
;       The TRUE value used will be returned through the variable if it was
;       not passed into the routine.
;
;    n_channels : out, optional, type=long
;       set to a named variable to get the number of channels (or bands) for
;       the image; will be 1, 2, 3, or 4
;-
function mg_image_getsize, im, true=true, n_channels=nchannels
  compile_opt strictarr
  on_error, 2

  ndims = size(im, /n_dimensions)
  dims = size(im, /dimensions)

  if (n_elements(true) eq 0L) then begin
    case ndims of
      2: true = 0L
      3: begin
          ind = where(dims eq 3L, count)
          if (count ge 1L) then begin
            true = ind[0] + 1L
            break
          endif

          ind = where(dims eq 2L, count)
          if (count ge 1L) then begin
            true = ind[0] + 1L
            break
          endif

          ind = where(dims eq 4L, count)
          if (count ge 1L) then begin
            true = ind[0] + 1L
            break
          endif

          message, 'images must have 2, 3, or 4 bands'
        end
      else: message, 'invalid dimensionality for image'
    endcase
  endif

  case true of
    0: nchannels = 1L
    1: nchannels = dims[0]
    2: nchannels = dims[1]
    3: nchannels = dims[2]
    else: message, 'invalid TRUE keyword value'
  endcase

  case true of
    0: return, dims[0:1]
    1: return, dims[1:2]
    2: return, dims[[0, 2]]
    3: return, dims[0:1]
    else: message, 'invalid TRUE keyword value'
  endcase
end


; main-level example program

filename = file_which('people.jpg')
ali = read_image(filename)
sz = mg_image_getsize(ali, true=true, n_channels=nchannels)
print, filename, format='(%"File: %s")'
print, sz, true, nchannels, $
       format='(%"Size: %d by %d, TRUE: %d, number of channels: %d")'

end

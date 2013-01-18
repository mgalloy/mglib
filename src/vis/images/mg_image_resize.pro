; docformat = 'rst'

;+
; Resize an image similarly to `CONGRID`. Advantage over `CONGRID` is that
; nearest neighbor interpolation is used even for multiple band images.
;
; :Returns:
;    the resized image
;
; :Params:
;    im : in, required, type=image array
;       input image array; if the image has multiple bands, use the TRUE
;       keyword to specify which dimension contains the channels
;    xsize : in, required, type=long
;       xsize of the output image
;    ysize : in, required, type=long
;       ysize of the output image
;
; :Keywords:
;    true : in, optional, type=long
;       set to specify which dimensions contains the channels; `TRUE=0` is for
;       m by n images, `TRUE=1` is for 3 by m by n images, `TRUE=2` is for
;       m by 3 by n images, `TRUE=3` is for m by n by 3 images; default is to
;       guess that the first dimension of size 3 is the number of channels
;    _extra : in, optional, type=keywords
;       keywords to `CONGRID`
;-
function mg_image_resize, im, xsize, ysize, true=true, _extra=e
  compile_opt strictarr
  on_error, 2

  if (n_elements(true) eq 0L) then begin
    dims = mg_image_getsize(im, true=_true)
  endif else _true = true

  if (n_params() ne 3L) then message, 'incorrect number of parameters'

  sz = size(im, /structure)
  case sz.n_dimensions of
    0: begin
        message, (sz.n_elements eq 0L) $
                   ? 'undefined input image' $
                   : 'images must be 2D or 3D'
      end
    1: message, 'images must be 2D or 3D'
    2: return, congrid(im, xsize, ysize, _extra=e)
    3: begin
        case _true of
          0: message, 'TRUE=0 is not valid for 3D images'
          1: dims = [3, xsize, ysize]
          2: dims = [xsize, 3, ysize]
          3: dims = [xsize, ysize, 3]
          else: message, 'invalid value for TRUE'
        endcase

        result = make_array(type=sz.type, dimension=dims)

        for c = 0L, 3L - 1L do begin
          d = c mod sz.dimensions[_true - 1L]
          case _true of
            1: result[c, *, *] = congrid(reform(im[d, *, *]), xsize, ysize, _extra=e)
            2: result[*, c, *] = congrid(reform(im[*, d, *]), xsize, ysize, _extra=e)
            3: result[*, *, c] = congrid(reform(im[*, *, d]), xsize, ysize, _extra=e)
          endcase
        endfor

        return, result
      end
    else: message, 'images must be 2D or 3D'
  endcase

end

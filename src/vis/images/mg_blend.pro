; docformat = 'rst'

;+
; Blend two images together using the given alpha channel.
;-


;+
; Given two type codes, return a type code of a variable that can contain the
; precision of both type codes. The promotion order of the types is shown in:
;
; .. image:: idl-type-promotion.png
;
; :Private:
;
; :Returns:
;    long
;
; :Params:
;    type1 : in, required, type=long
;       type code of the first variable
;    type2 : in, required, type=long
;       type code of the second variable
;-
function mg_blend_type, type1, type2
  compile_opt strictarr

  types = [[intarr(16) - 1], $ ; undefined
           [-1,  1,  2,  3,  4,  5,  6, -1, -1,  9, -1, -1, 12, 13, 14, 15], $ ; byte
           [-1,  2,  2,  3,  4,  5,  6, -1, -1,  9, -1, -1,  3, 14, 14,  4], $ ; int
           [-1,  3,  3,  3,  4,  5,  6, -1, -1,  9, -1, -1,  3, 14, 14,  4], $ ; long
           [-1,  4,  4,  4,  4,  5,  6, -1, -1,  9, -1, -1,  4,  4,  4,  4], $ ; float
           [-1,  5,  5,  5,  5,  5,  9, -1, -1,  9, -1, -1,  5,  5,  5,  5], $ ; double
           [-1,  6,  6,  6,  6,  9,  6, -1, -1,  9, -1, -1,  6,  6,  6,  6], $ ; complex
           [intarr(16) - 1], $ ; string
           [intarr(16) - 1], $ ; structure
           [-1,  9,  9,  9,  9,  9,  9, -1, -1,  9, -1, -1,  9,  9,  9,  9], $ ; dcomplex
           [intarr(16) - 1], $ ; pointer
           [intarr(16) - 1], $ ; object
           [-1, 12,  3,  3,  4,  5,  6, -1, -1,  9, -1, -1, 12, 13, 14, 15], $ ; uint
           [-1, 13, 14, 14,  4,  5,  6, -1, -1,  9, -1, -1, 13, 13, 14, 15], $ ; ulong
           [-1, 14, 14, 14,  4,  5,  6, -1, -1,  9, -1, -1, 14, 14, 14,  4], $ ; long64
           [-1, 15,  4,  4,  4,  5,  6, -1, -1,  9, -1, -1, 15, 15,  4, 15]] ; ulong64


  return, types[type1, type2]
end


;+
; Return the permutation array to TRANSPOSE an array from `TRUE=true1` to
; `TRUE=true2`.
;
; :Private:
;
; :Returns:
;    lonarr(3)
;
; :Params:
;    true1 : in, required, type=long
;       interleave of first image
;    true2 : in, required, type=long
;       interleave of second image
;-
function mg_blend_perm, true1, true2
  compile_opt strictarr

  allPerms = [[[0, 1, 2], [1, 0, 2], [1, 2, 0]], $
              [[1, 0, 2], [0, 1, 2], [0, 2, 1]], $
              [[2, 0, 1], [0, 2, 1], [0, 1, 2]]]

  return, reform(allPerms[*, true2 - 1L, true1 - 1L])
end


;+
; Blend two images together using the given alpha channel. If the images are
; of different interleaves they are converted to a common interleave:
;
;    * if one image is 2D and one is 3D, the 2D image is converted to the
;      interleave of the 3D image (using the current color table)
;    * if both images are 3D, the second image is converted to the interleave
;      of the first image
;
; :Examples:
;    Run the main-level program at the end of this file with::
;
;       IDL> .run mg_blend
;
;    This should produce:
;
;    .. image:: blended-earth.png
;
; :Returns:
;    image
;
; :Params:
;    im1 : in, required, type=image
;       first image to blend
;    im2 : in, required, type=image
;       second image to blend; must have the same xsize and ysize as im1, but
;       may have a different number of bands
;
; :Keywords:
;    alpha_channel : in, optional, type=float, default=0.5
;       value in 0.0 - 1.0; 1.0 is all im1 and 0.0 is all im2; can be a scalar
;       or a 2-dimensional image the same size as the combined images
;-
function mg_blend, im1, im2, alpha_channel=alphaChannel
  compile_opt strictarr
  on_error, 2

  _alphaChannel = n_elements(alphaChannel) eq 0L ? 0.5 : alphaChannel

  _im1 = im1
  _im2 = im2

  sz1 = size(_im1, /structure)
  sz2 = size(_im2, /structure)
  szAlpha = size(_alphaChannel, /structure)

  if (sz1.n_dimensions lt 2L || sz1.n_dimensions gt 3L) then begin
    message, 'images must have 2 or 3 dimensions'
  endif

  if (sz2.n_dimensions lt 2L || sz2.n_dimensions gt 3L) then begin
    message, 'images must have 2 or 3 dimensions'
  endif

  if (szAlpha.n_dimensions ne 0L && szAlpha.n_dimensions ne 2L) then begin
    message, 'ALPHA_CHANNEL must be a scalar or 2-dimensional'
  endif

  dims1 = mg_image_getsize(_im1, true=true1)
  dims2 = mg_image_getsize(_im2, true=true2)

  if (~array_equal(dims1, dims2)) then begin
    message, 'images must have matching sizes'
  endif

  if (n_elements(_alphaChannel) gt 1L) then begin
    dimsAlpha  = mg_image_getsize(_alphaChannel, true=trueAlpha)

    if (~array_equal(dims1, dimsAlpha)) then begin
      message, 'ALPHA_CHANNEL size must match image sizes if not a scalar'
    endif
  endif

  ; convert images to the same interleave
  if (sz1.n_dimensions ne sz2.n_dimensions) then begin
    ; one 2D image, one 3D image
    case 1 of
      sz1.n_dimensions eq 2L: _im1 = mg_maketrue(_im1, true=true2)
      sz2.n_dimensions eq 2L: _im2 = mg_maketrue(_im2, true=true1)
      else: message, 'invalid number of dimensions'
    endcase
  endif else begin
    ; both 2D images or both 3D images (but possibly different interleaves)
    if (sz1.n_dimensions eq 3L) then begin
      _im2 = transpose(_im2, mg_blend_perm(true1, true2))
    endif
  endelse

  ; convert alpha channel to the correct interleave if it is a channel
  if (n_elements(_alphaChannel) gt 1L) then begin

    if (true1 gt 0L) then begin
      _alphaChannel = reform(_alphaChannel, 1, dimsAlpha[0], dimsAlpha[1])
      _alphaChannel = rebin(_alphaChannel, 3, dimsAlpha[0], dimsAlpha[1])

      case true1 of
        1:
        2: _alphaChannel = transpose(_alphaChannel, [1, 0, 2])
        3: _alphaChannel = transpose(_alphaChannel, [1, 2, 0])
      endcase
    endif
  endif

  ; make result image the correct type (higher precision of the types of
  ; the two input images)
  return, fix(_alphaChannel * _im1 + (1.0 - _alphaChannel) * _im2, $
              type=mg_blend_type(sz1.type, sz2.type))
end


; main-level example program

scale = 4L

restore, filepath('globalwinds.dat', subdir=['examples','data'])

u = rebin(u, 128L * scale, 64L * scale)
v = rebin(v, 128L * scale, 64L * scale)
x = rebin(x, 128L * scale)
y = rebin(y, 64L * scale)

im = mg_lic(u, v)

earth = read_image(filepath('earth.jpg', subdir=['examples', 'demo', 'demodata']))
earth = mg_image_flip(earth)

blendedImage = mg_blend(mg_image_resize(earth, 512, 256), im)
lon = 180.0 * findgen(512) / 511.0 - 90.0
lat = 360.0 * findgen(256) / 255.0 - 180.0
mg_image, blendedImage, lon, lat, xticks=4, yticks=4, /interp

end

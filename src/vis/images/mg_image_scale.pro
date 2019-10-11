; docformat = 'rst'

;+
; Scale intensity values of single channel image.
;
; :Returns:
;   2-dimensional array of the same type as input
;
; :Params:
;   im : in, required, type=2-d array
;     single channel image to scale
;
; :Keywords:
;   minimum : in, optional, type=scalar of same type as im, default=0
;     value to scale `im_minimum` to
;   maximum : in, optional, type=scalar of same type as im, default=255
;     value to scale `im_maximum` to
;   im_minimum : in, optional, type=scalar of same type as im, default=min of im
;     minimum value of `im` to consider
;   im_maximum : in, optional, type=scalar of same type as im, default=max of im
;     maximum value of `im` to consider
;   exponent : in, optional, type=float, default=1.0
;     exponent to raise `im` to
;   type : in, optional, type=int, default=type code of im
;     `SIZE` type code to cast result to
;-
function mg_image_scale, im, $
                         minimum=minimum, maximum=maximum, $
                         im_minimum=im_minimum, im_maximum=im_maximum, $
                         exponent=exponent, $
                         type=type
  compile_opt strictarr
  on_error, 2

  n_dims = size(im, /n_dimensions)
  if (n_dims ne 2L) then begin
    message, string(n_dims, format='(%"invalid number of dimensions: %d")')
  endif

  input_type = size(im, /type)
  !null = where(input_type eq [0, 6, 7, 89, 10, 11], n_bad_types)
  if (n_bad_types gt 0L) then begin
    message, string(input_type, format='(%"invalid input type: %d")')
  endif

  output_type = mg_default(type, input_type)
  !null = where(output_type eq [0, 6, 7, 89, 10, 11], n_bad_types)
  if (n_bad_types gt 0L) then begin
    message, string(output_type, format='(%"invalid output type: %d")')
  endif

  _min = mg_default(minumum, fix(0, type=output_type))
  _max = mg_default(maximum, fix(255, type=output_type))
  _im_min = mg_default(im_minimum, fix(min(im), type=output_type))
  _im_max = mg_default(im_maximum, fix(max(im), type=output_type))

  if (n_elements(exponent) eq 0L) then begin
    scaled_im = _min > (_max - _min) * (im - _im_min) / (_im_max - _im_min) + _min < _max
  endif else begin
    intermediate_type = input_type eq 5 ? 5 : 4
    zero = fix(0, type=intermediate_type)
    one = fix(1, type=intermediate_type)

    intermediate_im =  zero > one * (im - _im_min) / (_im_max - _im_min) < one
    intermediate_im ^= exponent

    scaled_im = _min > (_max - _min) * intermediate_im / one + _min < _max
  endelse

  return, fix(scaled_im, type=output_type)
end


; main-level example progrqm

dims = lonarr(2) + 500L

im = dist(dims[0], dims[1])
im -= 0.3 * max(im)
window, xsize=3 * dims[0], ysize=dims[1], /free
tv, mg_image_scale(im), 0
tv, bytscl(im^0.5), 1
tv, mg_image_scale(im, exponent=0.5), 2

end

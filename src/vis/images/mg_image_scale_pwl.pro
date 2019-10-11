; docformat = 'rst'

;+
; Piecewise-linearly scale an image.
;
; :Examples:
;    Try the main-level example program at the end of this file::
;
;       IDL> .run mg_scaleimage
;
;    This example does the following scaling::
;
;       im = mg_scaleimage(elev, dividers=[0, 1, 256], outputs=[0, 144, 256])
;
;    Here, the interval 0..1 in the input image is scaled to 0..144, and
;    1..256 is scaled to 144..245.
;
; :Returns:
;    image of the same dimensions as the original and type float
;
; :Params:
;    im : in, required, type=2-dimensional array
;       input image (single band)
;
; :Keywords:
;    dividers : in, required, type=1-dimensional array
;       divider values in the scale of the input image
;    outputs : in, required, type=1-dimensional array
;       output values corresponding to the `DIVIDERS` values
;-
function mg_image_scale_pwl, im, dividers=dividers, outputs=outputs
  compile_opt strictarr

  bins = value_locate(dividers, im)

  result = im
  for b = 0L, max(bins) do begin
    ind = where(bins eq b, count)
    if (count eq 0L) then continue

    ; linearly scale elements in ind to _outputs[i].._outputs[i + 1]
    f = mg_linear_function(dividers[b:b+1], outputs[b:b+1])
    result[ind] = f[0] + f[1] * im[ind]
  endfor

  return, result
end


; main-level example program

elev = read_binary(file_which('elevbin.dat'), data_dims=[64, 64], data_type=1)
elev = rebin(elev, 64 * 8, 64 * 8)

tvlct, mg_cpt2ct('ngdc/ETOPO1.cpt')
mg_decomposed, 0, old_decomposed=odec

mg_image, read_image(file_which('elev_t.jpg')), /new_window
mg_image, mg_image_scale_pwl(elev, dividers=[0, 1, 256], outputs=[0, 144, 256]), $
          /new_window

mg_decomposed, odec

end

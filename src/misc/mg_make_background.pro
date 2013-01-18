; docformat = 'rst'

;+
; Make a random (but smoothed) background texture.
;
; :Params:
;   xsize : in, required, type=long
;     width of image
;   ysize : in, required, type=long
;     height of image
;-
function mg_make_background_random, xsize, ysize
  compile_opt strictarr

  z = randomu(seed, xsize, ysize)

  kernel_sizes = [5, 5, 5, 5]
  for i = 0, n_elements(kernel_sizes) - 1 do begin
    z = smooth(temporary(z), kernel_sizes[i], /edge_truncate)
  endfor

  z = z + sobel(z)
  z = z + sobel(z)

  return, z
end


;+
; Make a background for computer desktop.
;-
pro mg_make_background
  compile_opt strictarr

  xsize = 1440
  ysize = 900

  z0 = mg_make_background_random(xsize, ysize)
  z1 = sobel(z0)
  z2 = smooth(z1, 5, /edge_truncate)

  ;z = z - smooth(z, 5, /edge_truncate)
  ;z = z - smooth(z, 5, /edge_truncate)

  im = bytarr(3, xsize, ysize)

  ; Violet circles
  im[0, *, *] = bytscl(z0, top=63B) + 128B + 8B + 4B + 2B
  im[1, *, *] = bytscl(z0, top=63B) + 64B + 16B + 8B + 4B
  im[2, *, *] = bytscl(z0, top=15B) + 128B + 64B + 32B + 16B

  ; Blue circles
  ;im[0, *, *] = bytscl(z0, top=63B) + 64B + 16B + 8B
  ;im[1, *, *] = bytscl(z0, top=63B) + 64B + 16B + 8B
  ;im[2, *, *] = bytscl(z0, top=63B) + 64B + 64B

  ; Red circle
  ;im[2, *, *] = bytscl(z0, top=127B)
  ;im[1, *, *] = bytscl(z1, top=255B)
  ;im[0, *, *] = bytscl(z2, top=63B) + 128B

  window, /free, xsize=xsize, ysize=ysize, title='Background'
  tv, im, true=1

  write_png, 'violet_circles.png', im
end

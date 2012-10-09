; docformat = 'rst'

;+
; Example program demonstrating the use of `MG_LIC`. Run the main-level example
; program with::
;
;    IDL> .run mg_lic
;
; The first image is the direct output of `MG_LIC`:
;
; .. image:: lic_example1.png
;
; The next image introduces color by using HSV color coordinates with
; hue equal to red, saturation equal to the vector field magnitude, and
; value equal to `MG_LIC` output:
;
; .. image:: lic_example3.png
;
; The third image uses a color table to display the magnitude over the `MG_LIC`
; output:
;
; .. image:: lic_example3.png
;
; The second set of images are done with a smoothed instead of a random
; texture:
;
; .. image:: smooth_lic_example1.png
;
; .. image:: smooth_lic_example2.png
;
; .. image:: smooth_lic_example3.png
;-

;+
; Compute the line integral convolution for a vector field.
;
; :Returns:
;    bytarr(m, n)
;
; :Params:
;    u : in, required, type="fltarr(m, n)"
;       x-coordinates of vector field
;    v : in, required, type="fltarr(m, n)"
;       y-coordinates of vector field
;
; :Keywords:
;    texture : in, optional, type="bytarr(m, n)"
;       random texture map; it is useful to use the same texture map for
;       generating frames of a movie
;-
pro mg_lic, u, v, texture=texture
  compile_opt strictarr
  on_error, 2

  ; empty because `MG_LIC` is implemented in `mg_flow.c` as a DLM; this header
  ; is for documenting the routine

  message, 'MG_FLOW DLM not found'
end


scale = 4L

restore, filepath('globalwinds.dat', subdir=['examples','data'])

;ivector, u, v, x, y

u = rebin(u, 128L * scale, 64L * scale)
v = rebin(v, 128L * scale, 64L * scale)
x = rebin(x, 128L * scale)
y = rebin(y, 64L * scale)

startTime = systime(/seconds)
im = mg_lic(u, v)
endTime = systime(/seconds)

im = bytscl(im)

t = bytscl(smooth(randomu(seed, 128L * scale, 64L * scale), 3, /edge_truncate))
smoothIm = mg_lic(u, v, texture=t)
smoothIm = bytscl(smoothIm)
pinkIm = bytscl(mg_lic(u, v, texture=bytscl(mg_pinknoise(128L * scale, 64L * scale))))

window, xsize=128L * scale * 3, ysize=64L * scale * 3, $
        /free, title='LIC for globalwinds.dat'
tv, im, 0

mag = sqrt(u * u + v * v)
m = mag / max(mag)

h = bytarr(128L * scale, 64L * scale)
s = m
v = im / 255.0

color_convert, h, s, v, r, g, b, /hsv_rgb
im2 = bytarr(3L, 128L * scale, 64L * scale)
im2[0, *, *] = r
im2[1, *, *] = g
im2[2, *, *] = b

tv, im2, 1, true=1

mg_loadct, 9, /brewer

tvlct, ctr, ctg, ctb, /get

lic_image = bytarr(3L, 128L * scale, 64L * scale)
lic_image[0, *, *] = im
lic_image[1, *, *] = im
lic_image[2, *, *] = im

mscaled = bytscl(m)
m_image = fltarr(3L, 128L * scale, 64L * scale)
m_image[0, *, *] = ctr[mscaled] / 255.0
m_image[1, *, *] = ctg[mscaled] / 255.0
m_image[2, *, *] = ctb[mscaled] / 255.0
im3 = lic_image * m_image

tv, im3, 2, true=1

tv, smoothIm, 3

h = bytarr(128L * scale, 64L * scale)
s = m
v = smoothIm / 255.0

color_convert, h, s, v, r, g, b, /hsv_rgb

smoothIm2 = bytarr(3L, 128L * scale, 64L * scale)
smoothIm2[0, *, *] = r
smoothIm2[1, *, *] = g
smoothIm2[2, *, *] = b

tv, smoothIm2, 4, true=1

smooth_lic_image = bytarr(3L, 128L * scale, 64L * scale)
smooth_lic_image[0, *, *] = smoothIm
smooth_lic_image[1, *, *] = smoothIm
smooth_lic_image[2, *, *] = smoothIm

smoothIm3 = smooth_lic_image * m_image

tv, smoothIm3, 5, true=1

tv, pinkIm, 6

h = bytarr(128L * scale, 64L * scale)
s = m
v = pinkIm / 255.0

color_convert, h, s, v, r, g, b, /hsv_rgb

pinkIm2 = bytarr(3L, 128L * scale, 64L * scale)
pinkIm2[0, *, *] = r
pinkIm2[1, *, *] = g
pinkIm2[2, *, *] = b

tv, pinkIm2, 7, true=1

pink_lic_image = bytarr(3L, 128L * scale, 64L * scale)
pink_lic_image[0, *, *] = pinkIm
pink_lic_image[1, *, *] = pinkIm
pink_lic_image[2, *, *] = pinkIm

pinkIm3 = pink_lic_image * m_image

tv, pinkIm3, 8, true=1

print, format='(%"Time to compute: %0.1f seconds")', endTime - startTime

end

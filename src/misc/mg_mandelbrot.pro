; docformat = 'rst'

;+
; Function to perform the iteration required to calculate the mandelbrot set::
;
;   z[i+1] = z[i]^2 + c
;
; where c is the input complex number. The returned value depends on whether
; the z diverged or not. z is deemed to be diverging once |z| > z_max. If this
; occurs the returned value is the number of iterations it took to exceed z_max
; (i.e. how fast it is diverging). If |z| < z_max after maxiter iterations then
; we assume it is not diverging and return zero.
;
; Specifically, we return the "fractional escape count" using the "renormalized"
; iteration count formula::
;
;   N + 1 - log (log  |z(N)|) / log 2
;
; See: http://linas.org/art-gallery/escape/escape.html
;-
function mg_mandelbrot_iterate, c
  compile_opt strictarr

  maxiter = 256
  z_max = 2.0

  z = complex(0.0, 0.0)

  for i = 1, maxiter do begin
     z = z^2 + c
     if (abs(z) gt z_max) then begin
         i += 1.0 - alog(alog(abs(z))) / alog(2.0)
         break
     endif
  endfor
  if (i ge maxiter + 1.0) then i = 0.0
  return, float(i)
end


;+
; IDL procedure to calculate and plot the Mandelbrot set using the
; "escape time" method. The `M` set is the set of points on the complex plane
; `c = x + iy` for which the iteration `z[i+1] = z[i]^2 + c` does not diverge.
;
; :Keywords:
;   color_table : in, optional, type=long, default=39
;     color table to use for display
;   png_filename : in, optional, type=string
;     if present, save display to a PNG file given by `png_filename`
;-
pro mg_mandelbrot, color_table=ctable, png_filename=png_filename
  compile_opt strictarr

  _ctable = mg_default(ctable, 39)

  ; define an n*n square array for the positions on the complex
  ; plane, and the image intensity (output)

  n = 600
  c = complexarr(n, n)
  z = fltarr(n, n)

  ; define the centre and ranges of image to plot

  pos = complex(0.0, 0.0)
  range = complex(4.0, 4.0)

  ; use these to define the upper/lower X,Y ranges of the image

  xmin = real_part(pos - range / 2.0)
  xmax = real_part(pos + range / 2.0)
  ymin = imaginary(pos - range / 2.0)
  ymax = imaginary(pos + range / 2.0)

  ; set up the X,Y ranges as row,column vectors

  x = indgen(n) / float(n - 1) * (xmax - xmin) + xmin
  y = indgen(n) / float(n - 1) * (ymax - ymin) + ymin
  y = reform(y, 1, n)

  ; the complex n*n array 'c' defines points on the complex plane
  c_r = rebin(x, n, n, /sample)
  c_i = rebin(y, n, n, /sample)
  c = complex(c_r, c_i)

  ; for each pixel position apply the iteration formula
  for i = 0L, n_elements(c) - 1 do begin
    z[i] = mg_mandelbrot_iterate(c[i])
  endfor

  ; plot
  window, 0, xsize=n, ysize=n, retain=2
  device, get_decomposed=odec
  device, decomposed=0
  tvlct, rgb, /get
  loadct, _ctable
  tvlct, r, g, b, /get
  levels = indgen(200)^10.0
  levels = levels / max(levels) * max(z)
  contour, z, x, y, /fill, levels=levels, $
           xrange=[xmin, xmax], yrange=[ymin, ymax], xstyle=1, ystyle=1

  device, decomposed=odec
  tvlct, rgb

  ; output the image as a PNG file
  if (n_elements(png_filename) gt 0L) then begin
    im = tvrd()
    write_png, png_filename, im, r, g, b
  endif
end

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
  z_max = 2.0D

  z = dcomplex(0.0, 0.0)

  for i = 1, maxiter do begin
     z = z^2 + c
     if (abs(z) gt z_max) then begin
         i += 1.0D - alog(alog(abs(z))) / alog(2.0)
         break
     endif
  endfor
  if (i ge maxiter + 1.0D) then i = 0.0D
  return, double(i)
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
pro mg_mandelbrot, r_range=r_range, i_range=i_range, $
                   color_table=ctable, png_filename=png_filename
  compile_opt strictarr

  _ctable = mg_default(ctable, 39)

  ; define an n*n square array for the positions on the complex
  ; plane, and the image intensity (output)

  n = 600
  c = dcomplexarr(n, n)
  z = dblarr(n, n)

  ; use these to define the upper/lower X,Y ranges of the image
  _r_range = mg_default(r_range, [-2.0D, 2.0D])
  _i_range = mg_default(i_range, [-2.0D, 2.0D])
  xmin = _r_range[0]
  xmax = _r_range[1]
  ymin = _i_range[0]
  ymax = _i_range[1]

  ; set up the X,Y ranges as row,column vectors

  x = indgen(n) / double(n - 1) * (xmax - xmin) + xmin
  y = indgen(n) / double(n - 1) * (ymax - ymin) + ymin
  y = reform(y, 1, n)

  ; the complex n*n array 'c' defines points on the complex plane
  c_r = rebin(x, n, n, /sample)
  c_i = rebin(y, n, n, /sample)
  c = dcomplex(c_r, c_i)

  ; for each pixel position apply the iteration formula
  for i = 0L, n_elements(c) - 1 do begin
    z[i] = mg_mandelbrot_iterate(c[i])
  endfor

  ; plot
  window, xsize=n, ysize=n, retain=2, /free, $
          title=string(_r_range, _i_range, format='(%"Mandelbrot with R %f:%f and I %f:%f")')
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


; main-level example program

mg_mandelbrot, r_range=[-0.5, 0.0], i_range=[0.5, 1.0]

end

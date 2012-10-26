; docformat = 'rst'

;+
; Create an xkcd-style line.
;
; :Examples:
;   To try this routine, use the main-level program at the end of this file::
;
;     IDL> .run mg_xkcdify
;
;   This should produce:
;
;   .. image:: xkcdify.png
;
; :Returns:
;   `fltarr(2, n)`
;
; :Params:
;   x : in, required, type=fltarr
;     `x`-values
;   y : in, required, type=fltarr
;     `y`-values
;-
function mg_xkcdify, x, y
  compile_opt strictarr
  
  mag = 1.0
  f1 = 30L
  f2 = 0.05
  f3 = 15L

  xlim = mg_range(x)
  ylim = mg_range(y)

  if (xlim[1] eq xlim[0]) then xlim = ylim
  if (ylim[1] eq ylim[0]) then ylim = xlim

  x_scaled = (x - xlim[0]) / (xlim[1] - xlim[0])
  y_scaled = (y - ylim[0]) / (ylim[1] - ylim[0])

  dx = x_scaled[1:*] - x_scaled[0:-2]
  dy = y_scaled[1:*] - y_scaled[0:-2]
  dist_tot = total(sqrt(dx * dx + dy * dy))

  Nu = fix(200 * dist_tot)
  u = (findgen(nu) - 1.) / (Nu - 1.)

  res = mg_spline(x_scaled, y_scaled)

  x_int = reform(res[0, *])
  y_int = reform(res[1, *])

  dx = x_int[2:*] - x_int[0:-3]
  dy = y_int[2:*] - y_int[0:-3]
  d = sqrt(dx * dx + dy * dy)

  coeffs = mag * randomn(seed, n_elements(x_int) - 2) * 0.002
  b = hanning(f1, alpha=0.54)
  response = ir_filter(b, 1., coeffs)

  x_int[1:-2] += response * dy / d
  y_int[1:-2] += response * dx / d

  x_int = x_int[1:-2] * (xlim[1] - xlim[0]) + xlim[0]
  y_int = y_int[1:-2] * (ylim[1] - ylim[0]) + ylim[0]

  return, transpose([[[x_int], [y_int]]])
end

x = findgen(360) * !dtor

sin_res = mg_xkcdify(x, sin(x))
cos_res = mg_xkcdify(x, cos(x))

n = 200
yaxis = mg_xkcdify(fltarr(n), findgen(n) / (n - 1.) * 2.6 - 1.3)
;res = mg_xkcdify(x, 3.0 * x / 2. / !pi - 1.5)
xaxis = mg_xkcdify(findgen(n) / (n - 1.) * 2. * !pi, fltarr(n) - 1.3)

basename = 'xkcd-line'
mg_psbegin, /image, filename=basename + '.ps', xsize=6, ysize=4, /inches

mg_decomposed, 0

mg_fonts, tt_available=tt_available
preferred_font = 'Humor Sans'
if (total(tt_available eq preferred_font)) then begin
  font = preferred_font
endif else begin
  font = 'Helvetica'
endelse

device, set_font=font, /tt_font

tvlct, 0, 0, 0, 0
tvlct, 255, 255, 255, 1
tvlct, 255, 0, 0, 2
tvlct, 0, 0, 255, 3

plot, x, sin(x), $
      /nodata, $
      title='Cool xkcd-style plot!', $
      xstyle=5, ystyle=4, $
      color=0, background=1, font=1
plots, yaxis, thick=6, color=0, /data
plots, xaxis, thick=6, color=0, /data
plots, sin_res, thick=24, color=1, /data
plots, sin_res, thick=6, color=2, /data
plots, cos_res, thick=24, color=1, /data
plots, cos_res, thick=6, color=3, /data

mg_psend
mg_convert, basename, max_dimensions=[400, 400], output=im, /cleanup
mg_image, im, /new_window

end

; docformat = 'rst'

;+
; Found equations here::
;
;   http://ministryoftype.co.uk/words/article/guilloches/
;-

n = 1000
theta = findgen(n) / (n - 1) * 2. * !pi

r0 = 50.
r1 = -0.25
p = 25.
q = 3.
m = 1.
n = 6.

x = (r0 + r1) * cos(theta) + (r1 + p) * cos((r0 + r1) / r1 * theta)
y = (r0 + r1) * sin(theta) - (r1 + p) * sin((r0 + r1) / r1 * theta)

vis_psbegin, filename='pattern1.ps', xsize=5, ysize=5, /inches

green = vis_color('SeaGreen')
tvlct, green[0], green[1], green[2], 0

plot, mg_range(x), mg_range(y), /nodata, xstyle=5, ystyle=5, position=[0.05, 0.05, 0.95, 0.95]
plots, x, y, thick=0.5

vis_psend
vis_convert, 'pattern1', max_dimensions=[500, 500], output=im
file_delete, 'pattern1.ps'

window, /free, xsize=500, ysize=500
tvscl, im, true=1

x = (r0 + r1) * cos(m * theta) + (r1 + p) * cos((r0 + r1) / r1 * m * theta) + q * cos(n * theta)
y = (r0 + r1) * sin(m * theta) - (r1 + p) * sin((r0 + r1) / r1 * m * theta) + q * sin(n * theta)

vis_psbegin, filename='pattern2.ps', xsize=5, ysize=5, /inches

tan = vis_color('tan')
tvlct, tan[0], tan[1], tan[2], 0

plot, mg_range(x), mg_range(y), /nodata, xstyle=5, ystyle=5, position=[0.05, 0.05, 0.95, 0.95]
plots, x, y, thick=0.5

vis_psend
vis_convert, 'pattern2', max_dimensions=[500, 500], output=im
file_delete, 'pattern2.ps'

window, /free, xsize=500, ysize=500
tvscl, im, true=1

end


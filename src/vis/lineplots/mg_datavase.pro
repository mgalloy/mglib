; docformat = 'rst'

;+
; Based on the paper "Data Vases: Plots for Visualizing Multiple Time Series"
; by Sidharth Thakur and Theresa-Marie Rhyne.
;
; :Examples:
;   Try the main-level example program at the end of this file::
;
;     IDL> .run mg_datavase
;
;   This should produce the following:
;
;   .. image:: datavase.png
;-

;+
; Create a datavase plot.
;
; :Params:
;   x : in, required, type=fltarr(n)
;     independent variable
;   data : in, required, type="fltarr(m, n)"
;     `m` data sets of `n` elements each
;
; :Keywords:
;   xstyle : in, optional, type=integer default=0
;     style bitmask for x-axis
;   ystyle : in, optional, type=integer default=0
;     style bitmask for y-axis
;   axes_color : in, optional, type=integer
;     color for axes
;   colors : in, optional, type=integer, default='ffffff'x
;     colors for each dataset
;   _extra : in, optional, type=keywords
;     keywords to `PLOT`
;-
pro mg_datavase, x, data, $
                 xstyle=xstyle, ystyle=ystyle, $
                 axes_color=axesColor, colors=colors, $
                 _extra=e
  compile_opt strictarr

  _xstyle = n_elements(xstyle) eq 0L ? 0B : xstyle
  _ystyle = n_elements(ystyle) eq 0L ? 0B : ystyle

  _colors = n_elements(colors) eq 0L ? 'ffffff'x : colors
  ncolors = n_elements(colors)

  _minimum = min(data)
  _maximum = max(data)

  dims = size(data, /dimensions)
  nvases = dims[0]

  minx = min(x, max=maxx)
  xrange = [0, dims[0]]
  yrange = [minx, maxx]

  plot, xrange, yrange, /nodata, xrange=xrange, yrange=yrange, $
        xstyle=1B or _xstyle, ystyle=1B or _ystyle, $
        color=axesColor, _extra=e

  for d = 0L, nvases - 1L do begin
    dataset = reform(data[d, *]) / _maximum / 2.0

    outline_x = [d + 0.5 + dataset, reverse(d + 0.5 - dataset)]
    outline_y = [x, reverse(x)]
    plots, outline_x, outline_y, color=_colors[d mod ncolors]
    polyfill, outline_x, outline_y, color=_colors[d mod ncolors]
  endfor

  plot, xrange, yrange, /nodata, xrange=xrange, yrange=yrange, $
        xstyle=1B or _xstyle, ystyle=1B or _ystyle, $
        color=axesColor, _extra=e, /noerase
end


; main-level example program

nseries = 20
npoints = 100
ps = 1

if (keyword_set(ps)) then begin
  orig_device = !d.name
  mg_psbegin, filename='datavase.ps'
endif

mg_decomposed, 1, old_decomposed=old_dec
mg_loadct, 28, /brewer
tvlct, r, g, b, /get
indices = mg_rgb2index([[r], [g], [b]])

d = randomu(1L, nseries, npoints)
for s = 0L, nseries - 1L do d[s, *] = smooth(d[s, *], 5, /edge_truncate)
_min = min(d, max=_max)
d = (d - _min) / (_max - _min)

mg_window, xsize=7, ysize=2, /inches

mg_datavase, findgen(npoints), d, $
             colors=indices[0:8], axes_color='000000'x, background='ffffff'x, $
             charsize=0.7

mg_decomposed, old_dec
if (keyword_set(ps)) then begin
  mg_psend
  mg_convert, 'datavase', max_dimension=[700, 700], output=im
  mg_image, im, /new_window
endif

end

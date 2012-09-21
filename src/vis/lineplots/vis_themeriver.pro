; docformat = 'rst'

;+
; Create a theme river style plot.
;
; :Examples:
;    See the main-level program at the end of this file::
; 
;       IDL> .run vis_themeriver
; 
;    The first example is similar to an error plot:
;
;    .. image:: themeriver.png
;
;    The second example produces a stacked plot like:
;
;    .. image:: stacked_themeriver_plot.png
;
; :Categories:
;    direct graphics
;-

;+
; Create a theme river style plot.
;
; :Params:
;    x : in, required, type=fltarr(n)
;       x-coordinates of data
;    data : in, required, type="fltarr(nlines, n)"
;       multiple y-coordinates of data values (nlines number of datasets)
;    colors : in, required, type=bytarr(nlines - 1)
;       colors of shaded regions between datasets (starting from the bottom)
;
; :Keywords: 
;    show_lines : in, optional, type=lonarr
;       indices of dataset lines in data to overplot
;    axis_color : in, optional, type=color
;       color of axis
;    color : in, optional, type=color
;       colors of lines
;    _extra : in, optional, type=keywords
;       keywords to plot (for axis) and oplot (for dataset lines overplotted)
;-
pro vis_themeriver, x, data, colors, show_lines=showlines, $
                    axis_color=axiscolor, color=color, _extra=e
  compile_opt strictarr

  _x = reform(x)
  sz = size(data, /structure)
  nlines = sz.dimensions[0]

  _showlines = n_elements(showlines) eq 0L ? -1L : showlines

  if (nlines - 1L ne n_elements(colors)) then begin
    message, 'incorrect number of colors'
  endif

  mind = min(data, max=maxd)
  
  ; setup the coordinate system
  plot, _x, _x, yrange=[mind, maxd], xstyle=9, ystyle=8, /nodata, $
        color=axiscolor, _extra=e

  xvert = [_x,  reverse(_x), _x[0]]  
  for line = 0L, nlines - 1L do begin
    if (line ne nlines - 1L) then begin
      yvert = [reform(data[line, *]), $
               reverse(reform(data[line + 1L, *])), $
               data[line, 0L]]
      polyfill, xvert, yvert, color=colors[line]
    endif
  endfor

  for line = 0L, nlines - 1L do begin
    ind = where(_showlines eq line, show)
    if (show gt 0L) then begin
      oplot, _x, data[line, *], color=color, _extra=e
    endif
  endfor  
  
  ; repeated so that the axis is *above* the filled regions
  plot, x, x, yrange=[mind, maxd], xstyle=9, ystyle=8, /nodata, $
        color=axiscolor, _extra=e, /noerase  
end

; example creating a theme river plot similar to an error bar plot

n = 360
x = findgen(n) * !dtor
r = randomu(seed, n)
r = smooth(r, 5, /edge_truncate)
y = x * sin(x)
data = fltarr(7, n)
data[0, *] = y - 3 * r - 0.1
data[1, *] = y - 2 * r - 0.1
data[2, *] = y - r - 0.01
data[3, *] = y
data[4, *] = y + r + 0.1
data[5, *] = y + 2 * r + 0.1
data[6, *] = y + 3 * r + 0.1

vis_loadct, 16, /brewer
tvlct, rgb, /get
rgb = rgb[[50, 90, 130], *]
colors = vis_rgb2index(rgb)
colors = [colors, reverse(colors)]

window, title='Theme river example (error plot)', /free, xsize=600, ysize=300

device, get_decomposed=odec
device, decomposed=1

vis_themeriver, x, data, colors, show_lines=3, $
               color='000000'x, thick=2, linestyle=2, $
               ticklen=0.01, background='FFFFFF'x, axis_color='000000'x

; example creating a theme river plot similar to a stacked bar plot

n = 100
nsets = 5
v = randomu(seed, nsets, n)   ; this is the original dataset

y = fltarr(nsets + 2, n)  ; add two extra datasets for bottom and top
y[0, *] = 0.0   ; bottom
; the following line does a cumulative sum so that datasets are monotonically
; increasing; it's divided by a total for each set to normalize
y[1:nsets, *] = total(v, 1, /cumulative) / rebin(reform(total(v, 1), 1, n), nsets, n)
y[nsets + 1, *] = 1.0   ; top

window, title='Theme river example (stacked bar plot)', /free, xsize=600, ysize=300

device, decomposed=0
loadct, 5

vis_themeriver, findgen(n), y, 100 * bindgen(nsets + 1) / nsets + 100, background=255, axis_color=0
               
device, decomposed=odec

end

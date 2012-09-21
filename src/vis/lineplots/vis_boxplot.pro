; docformat = 'rst'

;+
; Create a box and whisker plot, also called a boxplot. Then boxplot for a set
; of values displays the smallest observation, lower quartile, median, upper
; quartile, and largest observation. In our case symbols, mark each value 
; shown and a line connects the lower quartile to the upper quartile (through 
; the median, of course).
;
; :Todo:
;    handle outliers: values 1.5 IQR (interquartile range, the range between
;    lower and upper quartiles) or more below the lower quartile or 1.5 or 
;    more above the upper quartile; values beyond 3.0 IQR are "extreme" 
;    outliers
;
;    make horizontal boxplots
;
; :Examples:
;    Run the main-level program at the end of this file::
; 
;       IDL> .run vis_boxplot
;
;    This should produce something like:
;
;    .. image:: boxplot.png 
;
; :Categories:
;    direct graphics
;-

;+
; Create a box and whisker plot.
;
; :Params:
;    data : in, required, type="fltarr(m, n)"
;       data to plot where each column represents a dataset which corresponds 
;       to a Tukey boxplot symbol in the output
;    x : in, optional, type=fltarr(m)
;       values for the x-axis
;
; :Keywords:
;    color : in, optional, type=color
;       default color of the foreground elements: axis, lines, and symbols
;    line_color : in, optional, type=color
;       overrides COLOR for the color of the line through the second and third
;       quartiles
;    symbol_color : in, optional, type=color
;       overrides COLOR for the color of the symbols
;    psym : in, optional, type=long, default=7
;       plotting symbol to use for the symbols
;    _extra : in, optional, type=keywords
;       keywords to PLOT and PLOTS
;-
pro vis_boxplot, data, x, $
                 color=color, $
                 line_color=lineColor, $
                 symbol_color=symbolColor, $
                 psym=psym, _extra=e
  compile_opt strictarr
  on_error, 2

  case size(data, /n_dimensions) of
    1: _data = reform(data, 1, n_elements(data)) 
    2: _data = data
    else: message, 'data must be 2-dimensional'
  endcase
  
  _psym = n_elements(psym) eq 0L ? 7 : psym
  _symbolColor = n_elements(symbolColor) eq 0L $
                   ? (n_elements(color) eq 0L ? 'ffffff'x : color) $
                   : symbolColor
  
  sz = size(_data, /structure)
    
  _x = n_elements(x) eq 0L ? findgen(sz.dimensions[0]) : x
  
  if (sz.dimensions[0] ne n_elements(_x)) then begin
    message, 'incorrect size of x-axis values'
  endif

  dataMax = max(_data, min=dataMin)
  
  if (n_elements(_x) lt 2) then begin
    delta = 1.0
  endif else begin
    delta = _x[1] - _x[0]
  endelse
  
  plot, [_x[0], _x[n_elements(_x) - 1L]], [dataMin, dataMax], /nodata, $
        xrange=[_x[0] - delta / 2., _x[sz.dimensions[0] - 1L] + delta / 2.], $
        xtickv=_x, color=color, _extra=e
  
  nrows = sz.dimensions[1]
  quartiles = long([0.25, 0.5, 0.75] * nrows)
  
  for r = 0L, n_elements(_x) - 1L do begin
    d = _data[r, *]
    d = d[sort(d)]
    
    q = d[quartiles]
    dmax = max(d, min=dmin)

    plots, [_x[r], _x[r]], [q[0], q[2]], color=lineColor, _extra=e    
    plots, fltarr(5) + _x[r], [dmin, q, dmax], psym=_psym, $
           color=_symbolColor, _extra=e
  endfor
end


; main-level example program

r = randomu(seed, 20)
y = sin(findgen(360) * !dtor)
d = r # y + randomu(seed, 20) * 0.5 # (fltarr(360) + 1.0)

vis_boxplot, d, xstyle=9, ystyle=9, yrange=[-1, 2], ticklen=0.01, $
             psym=vis_usersym(/horizontal_line, thick=2), symsize=0.75, $
             symbol_color='0000ff'x, line_color='aaaaaa'x, thick=2

end
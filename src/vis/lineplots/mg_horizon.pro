; docformat = 'rst'

;+
; Horizons graph squeeze many line plots into a single graph by folding the 
; graph into bands and color coding them. The reduced vertical space allows 
; for more datasets to be compared and anomolies to be spotted more quickly. 
; They are based on the following description::
;
;    http://www.panopticon.com/products/horizon.htm
;
; For example, this routine can produce the following plot:
; 
; .. image:: horizongraph.png
;
; :Categories:
;    direct graphics
;-

;+
; Plot a horizon graph.
;
; :Params:
;    x : in, required, type=fltarr(npoints)
;       x-values for all the datasets
;    data : in, required, type="fltarr(nseries, npoints)"
;      datasets
;
; :Keywords:
;    titles : in, optional, type=strarr(nseries)
;       y-axis titles for series
;    nbands : in, optional, type=long, default=6
;       number of bands to break data into, must be even
;    minimum : in, optional, type=numeric, default=min(data)
;       minimum value to use when dividing range into bands
;    maximum : in, optional, type=numeric, default=max(data)
;       maximum value to use when dividing range into bands
;    ystyle : in, optional, type=bitmask
;       YSTYLE keyword to PLOT (YSTYLE=1 is automatically used)
;    colors : in, optional, type=bytarr(nbands)
;       colors to use 
;    _extra : in, optional, type=keywords
;       keywords to PLOT
;-
pro mg_horizon, x, data, titles=titles, $
                nbands=nbands, minimum=minimum, maximum=maximum, $
                ystyle=ystyle, $
                colors=colors, $
                _extra=e
  compile_opt strictarr

  _ystyle = n_elements(ystyle) eq 0L ? 0B : ystyle
  
  _nbands = n_elements(nbands) eq 0L ? (n_elements(colors) eq 0L ? 6L : n_elements(colors)) : nbands
  
  _minimum = n_elements(minimum) eq 0L ? min(data) : minimum
  _maximum = n_elements(maximum) eq 0L ? max(data) : maximum
  bandsize = float(_maximum - _minimum) / _nbands
  
  dims = size(data, /dimensions)
  
  _colors = n_elements(colors) eq 0L ? bytscl(bindgen(_nbands)) : colors
  minx = min(x, max=maxx)
  xrange = [minx, maxx]
  yrange = [0, dims[0]]
  
  _titles = n_elements(titles) eq 0L ? sindgen(dims[0]) : titles

  plot, xrange, yrange, /nodata, xrange=xrange, yrange=yrange, $
        ystyle=1B or _ystyle, $
        ytickname=_titles, ytickv=findgen(dims[0]) + 0.5, yticks=dims[0] - 1L, $
        _extra=e
  
  for d = 0L, dims[0] - 1L do begin
    dataset = data[d, *]
    
    h = histogram(dataset, nbins=_nbands + 1L, min=_minimum, max=_maximum, $
                  reverse_indices=ri, locations=loc)

    ; flip values below center point
    center = (_maximum + _minimum) / 2.
    range = _maximum - _minimum
    dataset =  center + abs(center - dataset)
    
    bandorder = [reverse(lindgen(_nbands / 2L)), lindgen(_nbands / 2L)]
    
    for upperband = _nbands / 2, _nbands - 1L do begin
      lowerband = _nbands - 1L - upperband
      
      ; display upperband
      
      y = reform(dataset * 0.0)

      ; this band
      if (ri[upperband] ne ri[upperband + 1L]) then begin        
        ind = ri[ri[upperband]:ri[upperband + 1L] - 1L]
        y[ind] = _nbands * (dataset[ind] - bandsize * bandorder[upperband] - center) / range
      endif
              
      ; maximum if in "next" band        
      if (upperband lt _nbands - 1L && ri[upperband + 1L] ne ri[upperband + 2L]) then begin
        nextind = ri[ri[upperband + 1L]:ri[upperband + 2L] - 1L]
        y[nextind] = 1.0
      endif        

      polyfill, [minx, x, maxx], d + [0, y, 0], color=_colors[upperband]

      ; display lowerband

      y = reform(dataset * 0.0)

      ; this band
      if (ri[lowerband] ne ri[lowerband + 1L]) then begin
        ind = ri[ri[lowerband]:ri[lowerband + 1L] - 1L]
        y[ind] = _nbands * (dataset[ind] - bandsize * bandorder[lowerband] - center) / range
      endif
      
      ; maximum if in "next" band        
      if (lowerband gt 0 && ri[lowerband - 1L] ne ri[lowerband]) then begin
        nextind = ri[ri[lowerband - 1L]:ri[lowerband] - 1L]
        y[nextind] = 1.0
      endif        

      polyfill, [minx, x, maxx], d + [0, y, 0], color=_colors[lowerband]
    endfor
    
    ; plot values greater than max
    ind = where(dataset gt _maximum, count)
    if (count gt 0L) then begin
      y = reform(dataset * 0.0)
      y[ind] = 1.0
      polyfill, [minx, x, maxx], d + [0, y, 0], color=_colors[upperband - 1L]
    endif
    
    ; plot values less than min
    ind = where(dataset lt _minimum, count)
    if (count gt 0L) then begin
      y = reform(dataset * 0.0)
      y[ind] = 1.0
      polyfill, [minx, x, maxx], d + [0, y, 0], color=_colors[lowerband + 1L]
    endif    
  endfor

  plot, xrange, yrange, /nodata, xrange=xrange, yrange=yrange, $
        ystyle=1B or _ystyle, $
        ytickname=_titles, ytickv=findgen(dims[0]) + 0.5, yticks=dims[0] - 1L, $
        _extra=e, /noerase  
end


; main-level example program

nbands = 4
nseries = 10
npoints = 100

device, decomposed=0
mg_loadct, 22, /brewer
tvlct, 0, 0, 0, 0
tvlct, 255, 255, 255, 255

d = randomu(1L, nseries, npoints)
for s = 0L, nseries - 1L do begin
  d[s, *] = smooth(d[s, *], 5, /edge_truncate)
endfor
_min = min(d, max=_max)
d = (d - _min) / (_max - _min)


window, /free, xsize=600, ysize=nseries * 150
!p.multi = [0, 1, nseries]
for s = 0L, nseries - 1L do begin
plot, d[s, *], xstyle=9, ystyle=9, yrange=[0, 1]
  for b = 0L, nbands do begin
    oplot, [0, npoints - 1], fltarr(2) + b * 1. / nbands, linestyle=1
  endfor
endfor

!p.multi = 0
window, /free, xsize=600, ysize=nseries * 50 + 30
mg_horizon, findgen(npoints), d, nbands=nbands, $
            titles='Series ' + strtrim(lindgen(nseries) + 1, 2), $
            xstyle=9, ystyle=8, min=0., max=1., colors=[1, 85, 170, 254]

end

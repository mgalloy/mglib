; docformat = 'rst'

;+
; Create a legend in direct graphics plots.
;
; :Examples:
;    Try the main-level program at the end of this file::
;
;       IDL> .run mg_legend
;
;    This should look like:
;
;    .. image:: legend.png
;-

;+
; Create a legend.
;
; :Todo:
;    LINE_LENGTH and GAP should be specified in something besides normal 
;    coords
;
; :Keywords:
;    background : in, optional, type=color
;       background color of legend
;    item_color : in, optional, type=byte/long
;       color of each line/symbol for each item in the legend
;    item_linestyle : in, optional, type=long
;       linestyle of the line segment for each item in the legend
;    item_name : in, optional, type=string
;       name of each item in the legend
;    item_psym : in, optional, type=long
;       symbol to use for each item in the legend
;    item_symsize : in, optional, type=float
;       size of each symbol in the legend
;    item_thick : in, optional, type=float
;       thickness of each line segment in the legend
;    color : in, optional, type=byte/long'
;       color of item names
;    line_length : in, optional, type=float, default=0.15
;       length of item line segment
;    gap : in, optional, type=float, default=0.15
;       size of gap between item symbol/line and item name
;    frame : in, optional, type=boolean
;       set to put a frame around the legend
;    line_height : in, optional, type=float, default=0.0
;       height of a line of text in data coordinates i.e. 0..nitems-1
;    _extra : in, optional, type=keywords
;       keywords to PLOT, XYOUTS
;-
pro mg_legend, background=background, $
               item_color=itemColor, item_linestyle=itemLinestyle, $
               item_name=itemName, $
               item_psym=itemPsym, item_symsize=itemSymsize, $
               item_thick=itemThick, $
               color=color, line_length=lineLength, gap=gap, $
               frame=frame, line_height=lineHeight, $
               _extra=e
  compile_opt strictarr
  
  _lineLength = n_elements(lineLength) eq 0L ? 0.4 : lineLength
  _gap = n_elements(gap) eq 0L ? 0.2 : gap
  _frame = keyword_set(frame) ? 0B : 4B
  _lineHeight = n_elements(lineHeight) eq 0L ? 0.0 : lineHeight
  
  nitems = max([n_elements(itemColor), n_elements(itemLinestyle), $
                n_elements(itemName), n_elements(itemPsym)])

  plot, findgen(nitems + 1L) / (nitems), findgen(nitems + 1L), $
        /nodata, /noerase, ticklen=0., $
        xticks=1, xtickname=strarr(2) + ' ', $
        yticks=1, ytickname=strarr(2) + ' ', $
        xstyle=1B or _frame, ystyle=1B or _frame, _extra=e
        
  if (n_elements(background) gt 0L) then begin
    polyfill, [0., 1., 1., 0., 0.], [0., 0., nitems, nitems, 0.], $
              color=background
  endif

  plot, findgen(nitems + 1L) / (nitems), findgen(nitems + 1L), $
        /nodata, /noerase, ticklen=0., $
        xticks=1, xtickname=strarr(2) + ' ', $
        yticks=1, ytickname=strarr(2) + ' ', $
        xstyle=1B or _frame, ystyle=1B or _frame, _extra=e
          
  for i = 0L, nitems - 1L do begin
    icolor = n_elements(itemColor) eq 0L $
               ? 'ffffff'x $
               : itemColor[i mod n_elements(itemColor)]
    iname = n_elements(itemName) eq 0L $
              ? '' $
              : itemName[i mod n_elements(itemName)]
    ipsym = n_elements(itemPsym) eq 0L $
              ? 0L $
              : itemPsym[i mod n_elements(itemPsym)]    
    ilinestyle = n_elements(itemLinestyle) eq 0L $
                   ? 0L $
                   : itemLinestyle[i mod n_elements(itemLinestyle)]   
    iSymsize = n_elements(itemSymsize) eq 0L $
                 ? 1.0 $
                 : itemSymsize[i mod n_elements(itemSymsize)]
    iThick = n_elements(itemThick) eq 0L $
                 ? 1.0 $
                 : itemThick[i mod n_elements(itemThick)]
                                                     
    ipsym = n_elements(itemLinestyle) eq 0L ? ipsym : -ipsym  
    
    if (n_elements(itemLinestyle) ge 0L) then begin
      x = [0., _lineLength]
      y = fltarr(2) + nitems - i - 1L
    endif else begin
      x = [0.]
      y = [nitems - i - 1L]
    endelse

    plots, x + _gap, y + 0.5, $
           psym=ipsym, color=icolor, linestyle=ilinestyle, $
           symsize=iSymsize, thick=iThick, $
           _extra=e
    xyouts, (n_elements(itemLinestyle) gt 0L ? _lineLength : 0.) + 2 * _gap, $
            nitems - i - 1L + 0.5 - 0.5 * _lineHeight, $
            iname, $
            color=color, _extra=e
  endfor
end


; main-level example program
mg_decomposed, 0
mg_loadct, 0

square = mg_usersym(/square, /fill, rotation=45)

colors = mg_color(['orange', 'slateblue', 'yellow', 'red'], /index)
for c = 0L, n_elements(colors) - 1L do begin
  rgb = mg_index2rgb(colors[c])
  tvlct, rgb[0], rgb[1], rgb[2], c + 1
endfor
colors = bindgen(4) + 1B

psyms = [6, 7, square, 0]
symsizes = [1., 1., 1.5]
linestyles = [0, 1, 2]

d = randomu(seed, 100, 5)

plot, findgen(100),  1.5 * findgen(100) / 99., /nodata, xstyle=9, ystyle=9

for i = 0, 4 do begin
  d[*, i] = smooth(d[*, i], 5., /edge_truncate)  
  
  oplot, reform(d[*, i]), $
         color=colors[i mod n_elements(colors)], $
         psym=-psyms[i mod n_elements(psyms)], $
         symsize=symsizes[i mod n_elements(symsizes)], $
         thick=2, $
         linestyle=linestyles[i mod n_elements(linestyles)]
endfor

mg_legend, item_color=colors, $
           item_linestyle=linestyles, $
           item_thick=2, $
           item_name='Set ' + strtrim(indgen(5) + 1, 2), $
           item_psym=psyms, $
           item_symsize=symsizes, $
           frame=1, $
           gap=0.15, $
           line_length=0.25, $
           line_height=0.25, $
           position=[0.775, 0.60, 0.97, 0.95]

end
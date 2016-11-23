; docformat = 'rst'

;+
; Create a legend in direct graphics plots.
;
; Colors are specified according to the global color mode, either decomposed (as
; an integer from 0 to 'ffffff'x) or indexed color (0-255 from a color table).
;
; :Examples:
;    Try the main-level program at the end of this file::
;
;       IDL> .run mg_legend
;
;    This should look like:
;
;    .. image:: legend.png
;
; :Keywords:
;    background : in, optional, type=color
;       background color of legend
;    item_color : in, optional, type=color/array of colors
;       color of each line/symbol for each item in the legend
;    item_linestyle : in, optional, type=long/lonarr
;       linestyle of the line segment for each item in the legend
;    item_name : in, optional, type=strarr
;       name of each item in the legend
;    item_psym : in, optional, type=long/lonarr
;       symbol to use for each item in the legend
;    item_symsize : in, optional, type=float/fltarr
;       size of each symbol in the legend
;    item_thick : in, optional, type=float/fltarr
;       thickness of each line segment in the legend
;    color : in, optional, type=color
;       color of item names and frame, if present
;    line_length : in, optional, type=float, default=0.15
;       length of item line segment in normalized coordinates of the width of
;       the legend
;    gap : in, optional, type=float, default=0.15
;       size of gap between the left edge of the legend and the item symbol/line
;       as well as the distance between the item symbol/line and item name in
;       normalized coordinates of the width of the legend
;    frame : in, optional, type=boolean
;       set to put a frame around the legend
;    line_bump : in, optional, type=float, default=0.125
;       half the height of the text in normalized coordinates of the distance
;       between item lines; changing this value can help center the item
;       symbol/line to the item name text
;    _extra : in, optional, type=keywords
;       keywords to PLOT, XYOUTS
;-
pro mg_legend, background=background, $
               item_color=item_color, item_linestyle=item_linestyle, $
               item_name=item_name, $
               item_psym=item_psym, item_symsize=item_symsize, $
               item_thick=item_thick, $
               color=color, line_length=line_length, gap=gap, $
               frame=frame, line_bump=line_bump, $
               _extra=e
  compile_opt strictarr

  _line_length = n_elements(line_length) eq 0L ? 0.4 : line_length
  _line_bump = n_elements(line_bump) eq 0L ? 0.125 : line_bump
  _gap = n_elements(gap) eq 0L ? 0.2 : gap
  _frame = keyword_set(frame) ? 0B : 4B

  n_items = max([n_elements(item_color), n_elements(item_linestyle), $
                 n_elements(item_name), n_elements(item_psym)])

  plot, findgen(n_items + 1L) / n_items, $
        findgen(n_items + 1L) / n_items * (n_items + 0.5), $
        /nodata, /noerase, ticklen=0.0, $
        xticks=1, xtickname=strarr(2) + ' ', $
        yticks=1, ytickname=strarr(2) + ' ', $
        xstyle=1B or _frame, ystyle=1B or _frame, color=color, _extra=e

  if (n_elements(background) gt 0L) then begin
    polyfill, [0., 1., 1., 0., 0.], [0., 0., n_items + 0.5, n_items + 0.5, 0.], $
              color=background
  endif

  plot, findgen(n_items + 1L) / n_items, $
        findgen(n_items + 1L) / n_items * (n_items + 0.5), $
        /nodata, /noerase, ticklen=0.0, $
        xticks=1, xtickname=strarr(2) + ' ', $
        yticks=1, ytickname=strarr(2) + ' ', $
        xstyle=1B or _frame, ystyle=1B or _frame, color=color, _extra=e

  for i = 0L, n_items - 1L do begin
    icolor = n_elements(item_color) eq 0L $
               ? 'ffffff'x $
               : item_color[i mod n_elements(item_color)]
    iname = n_elements(item_name) eq 0L $
              ? '' $
              : item_name[i mod n_elements(item_name)]
    ipsym = n_elements(item_psym) eq 0L $
              ? 0L $
              : item_psym[i mod n_elements(item_psym)]
    ilinestyle = n_elements(item_linestyle) eq 0L $
                   ? 0L $
                   : item_linestyle[i mod n_elements(item_linestyle)]
    isymsize = n_elements(item_symsize) eq 0L $
                 ? 1.0 $
                 : item_symsize[i mod n_elements(item_symsize)]
    ithick = n_elements(item_thick) eq 0L $
                 ? 1.0 $
                 : item_thick[i mod n_elements(item_thick)]

    ipsym = n_elements(item_linestyle) eq 0L ? ipsym : -ipsym

    if (n_elements(item_linestyle) gt 0L) then begin
      x = [0., _line_length]
      y = fltarr(2) + (n_items - i - 1L + 0.5)
    endif else begin
      x = [0.]
      y = [(n_items - i - 1L + 0.5)]
    endelse

    plots, x + _gap, y + _line_bump, $
           psym=ipsym, color=icolor, linestyle=ilinestyle, $
           symsize=isymsize, thick=iThick, $
           _extra=e
    xyouts, (n_elements(item_linestyle) gt 0L ? _line_length : 0.) + 2 * _gap, $
            y[0], $
            iname, $
            color=color, _extra=e
  endfor
end


; main-level example program

if (n_elements(ps) eq 0) then ps = 0

xsize = 7.0
ysize = 3.0

if (keyword_set(ps)) then begin
  basename = 'legend_example'
  mg_psbegin, filename=basename + '.ps', /color
  charsize = 1.0
  font = 1
endif else begin
  charsize = 1.0
  font = 0
endelse

mg_window, xsize=xsize, ysize=ysize, /inches, title='MG_LEGEND example', /free

mg_decomposed, 0
mg_loadct, 0

; setup colors
colors = mg_color(['orange', 'slateblue', 'yellow', 'red'], /index)
for c = 0L, n_elements(colors) - 1L do begin
  rgb = mg_index2rgb(colors[c])
  tvlct, rgb[0], rgb[1], rgb[2], c + 1
endfor
colors = bindgen(4) + 1B

if (keyword_set(ps)) then begin
  tvlct, 200B, 200B, 200B, n_elements(colors) + 1     ; background
  tvlct, 0B, 0B, 0B, n_elements(colors) + 2  ; frame and item names
endif else begin
  tvlct, 80B, 80B, 80B, n_elements(colors) + 1     ; background
  tvlct, 255B, 255B, 255B, n_elements(colors) + 2  ; frame and item names
endelse

; rotate through these for each "data set"
square = mg_usersym(/square, /fill, rotation=45)
psyms      = [6, 7, square, 0]
symsizes   = [1.0, 1.0, 1.5]
linestyles = [0, 1, 2]

; number of "data sets" to plot
n = 8
d = randomu(seed, 100, n)

; smooth data to be able to follow a curve more easily
for i = 0L, n - 1L do begin
  for s = 0L, 3L do d[*, i] = smooth(d[*, i], 5., /edge_truncate)
endfor

; set coordinates
plot, findgen(100), findgen(100), /nodata, xstyle=9, ystyle=9, $
      font=font, charsize=charsize, $
      yrange=[min(d), 1.4]

; plot each "data set"
for i = 0L, n - 1L do begin
  oplot, reform(d[*, i]), $
         color=colors[i mod n_elements(colors)], $
         psym=-psyms[i mod n_elements(psyms)], $
         symsize=symsizes[i mod n_elements(symsizes)], $
         thick=2, $
         linestyle=linestyles[i mod n_elements(linestyles)]
endfor

; add legend
mg_legend, item_color=colors, $
           item_linestyle=linestyles, $
           item_thick=2, $
           item_name='Set ' + strtrim(indgen(n) + 1, 2), $
           item_psym=psyms, $
           item_symsize=symsizes, $
           frame=1, $
           font=font, $
           charsize=charsize, $
           background=n_elements(colors) + 1, $
           color=n_elements(colors) + 2, $
           gap=0.15, $
           line_length=0.25, $
           position=[0.85, 0.97 - (ysize / 65.0) * n, 0.97, 0.97]

if (keyword_set(ps)) then begin
  mg_psend
  ;mg_convert, basename, max_dimensions=[650, 325], /to_png
  mg_convert, basename, max_dimensions=[650, 325], output=im, /cleanup
  mg_image, im, /new_window
endif

end

; docformat = 'rst'

;+
; Produce a colorbar in direct graphics. Uses the colors in the current color
; table along with the indices from `COLORS` (or, alternatively using `BOTTOM`
; and `NCOLORS`) if the `RED`, `GREEN`, and `BLUE` keywords are not set.
;
; :Categories:
;    direct graphics
;
; :Examples:
;    Running the main-level program at the end of the file should produce
;    something like:
;
;    .. image:: colorbar.png
;
;    Colorbars can be created in indexed color or decomposed color. It can be
;    useful to draw a colorbar when in decomposed color by specifying the the
;    colortable colors with the `RED`, `GREEN`, and `BLUE` keywords and the
;    color of the axis with `AXIS_COLOR` (as a long integer like `'00ffff'x`).
;-

;+
; Produce a colorbar in direct graphics.
;
; :Keywords:
;    range : in, optional, type=fltarr(2), default="[0., 1.]"
;       data range of the colorbar
;    colors : in, optional, type=bytarr, default=bindgen(256)
;       colors to use in the colorbar
;    bottom : in, optional, type=long, default=0L
;       first color index to place in the colorbar; ignored if COLORS is
;       specified
;    ncolors : in, optional, type=long, default=256L
;       number of colors to place in the colorbar; ignored if COLORS is
;       specified
;    vertical : in, optional, type=boolean
;       set to display a vertical colorbar; either VERTICAL or HORIZONTAL must
;       be set
;    horizontal : in, optional, type=boolean
;       set to display a horizontal colorbar; either VERTICAL or HORIZONTAL
;       must be set
;    axis_color : in, optional, type=color
;       color of axis, labels, etc.
;    labels_on_right : in, optional, type=boolean
;       set to place axis labels on the right instead of the left on vertical
;       colorbars
;    labels_on_top : in, optional, type=boolean
;       set to place axis labels on the top instead of the bottom on
;       horizontal colorbars
;    red : in, optional, type=bytarr(256), default=current color table
;       red values of the color table to display; uses the current color
;       table if RED is not present
;    green : in, optional, type=bytarr(256), default=current color table
;       green values of the color table to display; uses the current color
;       table if GREEN is not present
;    blue : in, optional, type=bytarr(256), default=current color table
;       blue values of the color table to display; uses the current color
;       table if BLUE is not present
;    divisions : in, optional, type=long, default=6L
;       number of tick intervals along the length of the colorbar; there will
;       be one more tick mark
;    xticklen : in, optional, type=float
;       length of tick marks for horizontal colorbars
;    yticklen : in, optional, type=float
;       length of tick marks for vertical colorbars
;    ticklen : in, optional, type=float
;       length of tick marks on colorbar
;    _extra : in, optional, type=keywords
;       keywords to `MG_IMAGE`
;-
pro mg_colorbar, range=range, $
                 colors=colors, bottom=bottom, ncolors=ncolors, $
                 vertical=vertical, horizontal=horizontal, $
                 axis_color=axisColor, $
                 labels_on_right=labelsOnRight, $
                 labels_on_top=labelsOnTop, $
                 red=red, green=green, blue=blue, $
                 divisions=divisions, $
                 xticklen=xticklen, yticklen=yticklen, ticklen=ticklen, $
                 _extra=e
  compile_opt strictarr
  on_error, 2

  _divisions = n_elements(dimgions) eq 0L ? 6L : dimgions
  _range = n_elements(range) eq 0L ? [0, 255] : range

  if (n_elements(colors) gt 0L) then begin
    _colors = colors
  endif else begin
    _bottom = n_elements(bottom) eq 0L ? 0L : bottom
    _ncolors = n_elements(ncolors) eq 0L ? (256L - _bottom) : ncolors
    _colors = bindgen(_ncolors) + _bottom
  endelse

  case 1 of
    keyword_set(vertical): begin
        _im = (bytarr(2) + 1B) # _colors

        mg_decomposed, 0, old_decomposed=oldDecomposed

        if (n_elements(red) gt 0L $
              && n_elements(green) gt 0L $
              && n_elements(blue) gt 0L) then begin
          tvlct, origRed, origGreen, origBlue, /get
          tvlct, red, green, blue
        endif

        if (!d.name eq 'PS') then begin
          plot, [0, 1], _range, /nodata, /noerase, $
                xticks=1, xtickname=strarr(2) + ' ', $
                yticks=1, ytickname=strarr(2) + ' ', $
                ticklen=0., xstyle=5, ystyle=5, _extra=e
          inc = (double(_range[1]) - double(_range[0])) / double(n_elements(_colors))
          ys = inc * dindgen(n_elements(_colors)) + _range[0]
          for c = 0L, n_elements(_colors) - 1L do begin
            polyfill, [0.D, 1.D, 1.D, 0.D, 0.D], $
                      ys[[c, c, c + 1L, c + 1L, c]], $
                      color=_colors[c]
          endfor
        endif else begin
          mg_image, _im, [0, 1], _range, /axes, /noerase, $
                    xticks=1, xtickname=strarr(2) + ' ', $
                    yticks=1, ytickname=strarr(2) + ' ', $
                    ticklen=0., /no_scale, _extra=e
        endelse

        if (n_elements(red) gt 0L $
              && n_elements(green) gt 0L $
              && n_elements(blue) gt 0L) then begin
          tvlct, origRed, origGreen, origBlue
        endif

        mg_decomposed, oldDecomposed

        axis, yaxis=keyword_set(labelsOnRight), $
              yticks=_divisions, yrange=_range, ystyle=1, $
              yticklen=yticklen, ticklen=ticklen, $
              color=axisColor, _extra=e
      end
    keyword_set(horizontal): begin
        _im = _colors # (bytarr(2) + 1B)

        mg_decomposed, 0, old_decomposed=oldDecomposed

        if (n_elements(red) gt 0L $
              && n_elements(green) gt 0L $
              && n_elements(blue) gt 0L) then begin
          tvlct, origRed, origGreen, origBlue, /get
          tvlct, red, green, blue
        endif

        if (!d.name eq 'PS') then begin
          plot, _range, [0, 1], /nodata, /noerase, $
                xticks=1, xtickname=strarr(2) + ' ', $
                yticks=1, ytickname=strarr(2) + ' ', $
                ticklen=0., xstyle=5, ystyle=5, _extra=e
          inc = (double(_range[1]) - double(_range[0])) / double(n_elements(_colors))
          xs = inc * dindgen(n_elements(_colors) + 1L) + _range[0]
          for c = 0L, n_elements(_colors) - 1L do begin
            polyfill, xs[[c, c, c + 1L, c + 1L, c]], $
                      [0.D, 1.D, 1.D, 0.D, 0.D], $
                      color=_colors[c]
          endfor
        endif else begin
          mg_image, _im, _range, [0, 1], /axes, /noerase, $
                    xticks=1, xtickname=strarr(2) + ' ', $
                    yticks=1, ytickname=strarr(2) + ' ', $
                    ticklen=0., /no_scale, _extra=e
        endelse

        if (n_elements(red) gt 0L $
              && n_elements(green) gt 0L $
              && n_elements(blue) gt 0L) then begin
          tvlct, origRed, origGreen, origBlue
        endif

        mg_decomposed, oldDecomposed

        axis, xaxis=keyword_set(labelsOnTop), $
              xticks=_divisions, xrange=_range, xstyle=1, $
              xticklen=xticklen, ticklen=ticklen, $
              color=axisColor, _extra=e
      end
    else: message, 'either VERTICAL or HORIZONTAL must be set'
  endcase
end


; main-level example program

nlevels = 8
mg_loadct, 3, ncolors=nlevels + 2

h = hanning(20, 20)

charsize = keyword_set(ps) ? 0.5 : 1.0
ps = 1

; example using indexed color mode

if (keyword_set(ps)) then mg_psbegin, filename='colorbar-vertical.ps'

mg_decomposed, 0, old_decomposed=dec
mg_window, /free, title='Vertical colorbar', xsize=3, ysize=2.25, /inches

mg_contour, h, nlevels=nlevels, position=[0.1, 0.1, 0.8, 0.95], $
            xstyle=1, ystyle=1, /fill, c_colors=bindgen(nlevels) + 1B, charsize=charsize
mg_contour, h, nlevels=nlevels, position=[0.1, 0.1, 0.8, 0.95], /overplot

mg_colorbar, /vertical, position=[0.83, 0.1, 0.86, 0.95], yticklen=-0.05, $
             divisions=nlevels, range=[min(h, max=maxh), maxh], /labels_on_right, $
             colors=bindgen(nlevels) + 1B, charsize=charsize

mg_decomposed, dec
if (keyword_set(ps)) then mg_psend

if (keyword_set(ps)) then begin
  mg_convert, 'colorbar-vertical', max_dimensions=[300, 300], output=im
  mg_image, im, /new_window, title='PS vertical colorbar'
endif


; example using decomposed color

mg_loadct, 3
tvlct, r, g, b, /get

if (keyword_set(ps)) then mg_psbegin, filename='colorbar-horizontal.ps'

mg_decomposed, 1, old_decomposed=dec
mg_window, /free, title='Horizontal colorbar', xsize=2.5, ysize=2.75, /inches

mg_contour, h, nlevels=nlevels, position=[0.1, 0.1, 0.95, 0.85], /fill, $
            xstyle=1, ystyle=1, charsize=charsize
mg_contour, h, nlevels=nlevels, position=[0.1, 0.1, 0.95, 0.85], /overplot

mg_colorbar, /horizontal, position=[0.1, 0.89, 0.95, 0.92], $
             xticklen=-0.05, $
             divisions=4, range=[min(h, max=maxh), maxh], $
             /labels_on_top, $
             charsize=charsize, $
             red=r, green=g, blue=b, $
             axis_color=keyword_set(ps) ? '000000'x : 'ffffff'x

mg_decomposed, dec
if (keyword_set(ps)) then mg_psend

if (keyword_set(ps)) then begin
  mg_convert, 'colorbar-horizontal', max_dimensions=[300, 300], output=im
  mg_image, im, /new_window, title='PS horizontal window'
endif

end

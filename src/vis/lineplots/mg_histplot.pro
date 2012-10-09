; docformat = 'rst'

;+
; Create a histogram plot.
;
; :Examples:
;    See the main-level example program at the end of this file. Run it with::
;
;       IDL> .run mg_histplot
;
;    This should result in::
;
;    .. image:: histogram.png
;
; :Categories:
;    direct graphics
;-

;+
; Create a histogram plot.
;
; :Params:
;    x : in, required, type=numeric array
;       data to plot, or x-values of data if y is present
;    y : in, optional, type=numeric array
;       data to plot
;
; :Keywords:
;    _extra : in, optional, type=keywords
;       keywords to `MG_STEPCHART`
;-
pro mg_histplot, x, y, _extra=e
  compile_opt strictarr
  on_error, 2

  case n_params() of
    0: message, 'incorrect number of parameters'
    1: begin
        _x = findgen(n_elements(x) + 1L)
        _y = [x, x[n_elements(x) - 1L]]
      end
    2: begin
        _x = [x, x[n_elements(x) - 1L] + x[1] - x[0]]
        _y = [y, y[n_elements(y) - 1L]]
      end
  endcase

  mg_stepchart, _x, _y, _extra=e
end


; main-level example

marsFilename = file_which('marsglobe.jpg')
mars = read_image(marsFilename)

binsize = 2
mg_decomposed, 0, old_decomposed=odec

mg_loadct, 39

pattern = mg_checkerboard(block_size=2, colors=[0, 150])

redH = histogram(mars[0, *, *], binsize=binsize, min=0, max=255)
greenH = histogram(mars[1, *, *], binsize=binsize, min=0, max=255)
blueH = histogram(mars[2, *, *], binsize=binsize, min=0, max=255)

redH[0] = 0
greenH[0] = 0
blueH[0] = 0

mg_histplot, findgen(256 / binsize) * binsize, redH, $
             xstyle=9, ystyle=9, yrange=[0, 10000], $
             /fill, color=250, axis_color=255
mg_histplot, findgen(256 / binsize) * binsize, greenH, $
             /fill, /overplot, $
             color=150, pattern=pattern
mg_histplot, findgen(256 / binsize) * binsize, blueH, $
             /fill, /overplot, $
             color=75, /line_fill, orientation=45, spacing=0.1

mg_decomposed, odec

end
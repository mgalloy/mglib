; docformat = 'rst'

;+
; Create a histogram plot.
;
; :Examples:
;    See the main-level example program at the end of this file. Run it with::
;
;       IDL> .run mg_histplot
;
;    This should result in:
;
;    .. image:: histplot-example.png
;
; Another histogram plot example:
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

mg_psbegin, filename='histplot.ps', xsize=6, ysize=3, /inches, /image

binsize = 2
mg_decomposed, 1, old_decomposed=dec

mg_loadct, 39

pattern = mg_checkerboard(block_size=2, colors=[0, 150])

redH = histogram(mars[0, *, *], binsize=binsize, min=0, max=255, locations=bins)
greenH = histogram(mars[1, *, *], binsize=binsize, min=0, max=255)
blueH = histogram(mars[2, *, *], binsize=binsize, min=0, max=255)

; set first bin to 0, otherwise it would overwhelm the plot
redH[0] = 0
greenH[0] = 0
blueH[0] = 0

spacing = 0.1
mg_histplot, bins, redH, $
             xstyle=9, ystyle=9, yrange=[0, 10000], ticklen=-0.01, $
             /fill, color='ff0000'x, /line_fill, orientation=0, spacing=spacing, $
             axis_color='000000'x, charsize=1.0
mg_histplot, bins, greenH, $
             /fill, /overplot, $
             color='00ff00'x, /line_fill, orientation=-60, spacing=spacing;pattern=pattern
mg_histplot, bins, blueH, $
             /fill, /overplot, $
             color='0000ff'x, /line_fill, orientation=60, spacing=spacing

mg_decomposed, dec
mg_psend

mg_convert, 'histplot', max_dimensions=[350, 350], output=im
mg_image, im, /new_window

end

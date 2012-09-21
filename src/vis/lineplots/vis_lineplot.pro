; docformat = 'rst'

;+
; Create a line plot.
;
; :Examples:
;    Run the main-level program at the end of this file::
;
;       IDL> .run vis_lineplot 
;
; :Categories:
;    direct graphics
;-


;+
; Create a line plot.
;
; :Params:
;    x : in, required, type=fltarr
;    y : in, required, type=fltarr
;
; :Keywords:
;    thick : in, optional, type=float
;       thickness of lines in the line plot
;    color : in, optional, type=color
;       color of the line
;    _extra : in, optional, type=keywords
;       keywords to PLOT and PLOTS
;-
pro vis_lineplot, x, y, thick=thick, color=color, _extra=e
  compile_opt strictarr
  on_error, 2
  
  _thick = n_elements(thick) eq 0L ? 1.0 : thick
  _color = n_elements(color) eq 0L ? 'ffffff'x : color
  
  case n_params() of
    0: message, 'incorrect number of parameters'
    1: begin
        _x = findgen(n_elements(x))
        _y = x
      end
    2: begin
        _x = x
        _y = y
      end
  endcase
  
  plot, _x, _y, /nodata, _extra=e
  
  ncolors = n_elements(_color)
  nthick = n_elements(_thick)
  for s = 0L, n_elements(_x) - 2L do begin
    plots, [_x[s], _x[s+1]], [_y[s], _y[s+1]], $
           color=_color[s mod ncolors], thick=_thick[s mod nthick]
  endfor
end



; main-level example program

vis_psbegin, filename='lineplot.ps', xsize=5, ysize=3, /inches, /image
vis_decomposed, 0, old_decomposed=dec

vis_loadct, 0
y = sin(findgen(360) * !dtor)
vis_lineplot, y, color=congrid(bindgen(256), 360), thick=10 * abs(y), xstyle=1

vis_decomposed, dec
vis_psend

vis_convert, 'lineplot', max_dimensions=[500, 500], output=im
vis_image, im, /new_window
file_delete, 'lineplot.' + ['ps', 'png']

end

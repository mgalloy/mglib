; docformat = 'rst'

;+
; Wrapper to PLOTS to specify COLOR and THICK on a per point basis.
;
; :Examples:
;    Run the main-level program at the end of this file::
;
;       IDL> .run vis_plots
;
;    This should output something like:
;
;    .. image:: plots.png
;    
; :Categories:
;    direct graphics
;-


;+
; Wrapper to PLOTS to specify COLOR and THICK on a per point basis.
;
; :Params:
;    x : in, required, type="fltarr(n)/fltarr(2, n)/fltarr(3, n)"
;       x-coordinates of points or alternatively a 2 by n or 3 by n array with 
;       all the point data
;    y : in, optional, type=fltarr(n)
;       y-coordinates of points
;    z : in, optional, type=fltarr(n)
;       z-coordinates of points
;
; :Keywords:
;    thick : in, optional, type=float
;       thickness of lines in the line plot
;    color : in, optional, type=color
;       color of the line
;    _extra : in, optional, type=keywords
;       keywords to PLOT and PLOTS
;-
pro vis_plots, x, y, z, thick=thick, color=color, _extra=e
  compile_opt strictarr
  on_error, 2
  
  _thick = n_elements(thick) eq 0L ? 1.0 : thick
  _color = n_elements(color) eq 0L ? 'ffffff'x : color

  ncolors = n_elements(_color)
  nthick = n_elements(_thick)
    
  case n_params() of
    0: message, 'incorrect number of parameters'
    1: begin
        dims = size(x, /dimensions)
        case dims[0] of
          2: vis_plots, reform(x[0, *]), reform(x[1, *]), $
                        thick=thick, color=color, _extra=e
          3: vis_plots, reform(x[0, *]), reform(x[1, *]), reform(x[2, *]), $
                        thick=thick, color=color, _extra=e
          else: message, 'invalid dimensions of X array'
        endcase
      end
    2: begin
        for s = 0L, n_elements(x) - 2L do begin
          plots, [x[s], x[s+1]], [y[s], y[s+1]], $
                 color=_color[s mod ncolors], thick=_thick[s mod nthick]
        endfor          
      end
    3: begin
        for s = 0L, n_elements(x) - 2L do begin
          plots, [x[s], x[s+1]], [y[s], y[s+1]], [z[s], z[s+1]], $
                 color=_color[s mod ncolors], thick=_thick[s mod nthick]
        endfor          
      end
  endcase
end


; main-level example program

vis_psbegin, filename='plots.ps', /image
vis_window, /free, xsize=4, ysize=4, /inches
vis_decomposed, 1

pts = [[0, 0], [0.25, 0.1], [0.2, 0.5], [0.6, 0.5], [1.0, 1.0]]
pts = vis_spline(pts[0, *], pts[1, *], n_points=100)

dims = size(pts, /dimensions)
thick = randomu(seed, dims[1])
for s = 0, 2 do thick = smooth(thick, 5, /edge_truncate)

plot, [0, 1], [0, 1], /nodata, position=[0.1, 0.1, 0.95, 0.95]
vis_plots, pts, color='000000'x, thick=10. * reform(pts[0, *])

vis_psend
vis_convert, 'plots', max_dimensions=[300, 300], output=im
vis_image, im, /new_window
file_delete, 'plots.' + ['ps', 'png']

end

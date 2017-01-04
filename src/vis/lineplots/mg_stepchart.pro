; docformat = 'rst'

;+
; Plot a stepchart i.e. time series data were the current value changes at
; a particular time not gradually over time (see example below).
;
; :Todo:
;    * need to set baseline instead of assuming it is zero
;
; :Examples:
;    Main-level program is at the end of this file::
;
;       IDL> .run mg_stepchart
;
;    This should produce output similar to
;
;    .. image:: step.png
;
;    If the `RISER_THICK` is set to `0.0`, no risers are shown:
;
;    .. image:: step-noriser.png
;
; :Categories:
;    direct graphics
;-

;+
; Plot the flat portions of a graph on a predefined coordinate system.
;
; :Params:
;    x : in, required, type=fltarr(n)
;       x-coordinates of expanded data
;    y : in, required, type=fltarr(n)
;       y-coordinates of expanded data
;
; :Keywords:
;    thick : in, optional, type=fltarr
;       thicknes of flat portions of the graph
;    fill : in, optional, type=boolean
;       set to fill under the plot
;    color : in, optional, type=color
;       color of steps
;    _extra : in, optional, type=keywords
;       keywords to `PLOTS`
;-
pro mg_stepchart_plotflats, x, y, thick=thick, fill=fill, color=color, _extra=e
  compile_opt strictarr

  for s = 0L, n_elements(x) / 2 - 1L do begin
    if (keyword_set(fill)) then begin
      polyfill, [x[2 * s], x[2 * s], x[2 * s + 1], x[2 * s + 1]], $
                [0, y[2 * s], y[2 * s + 1], 0], $
                thick=thick, color=color, _extra=e
    endif
    plots, [x[2 * s], x[2 * s + 1]], [y[2 * s], y[2 * s + 1]], thick=thick, color=color, _extra=e
  endfor
end


;+
; Plot the stepchart.
;
; :Params:
;    x : in, required, type=fltarr(n)
;       x-coordinates if both x and y are passed; y-coordinates if only x is
;       passed
;    y : in, optional, type=fltarr(n)
;       y-coordinates
;
; :Keywords:
;    overplot : in, optional, type=boolean
;       set to overplot
;    thick : in, optional, type=float, default=1.0
;       thickness of lines
;    riser_thick : in, optional, type=float, default=0.5 * thick
;       thickness of "riser" line segments; set to 0.0 to not show risers
;    fill : in, optional, type=boolean
;       set to fill under the plot
;    color : in, optional, type=color
;       color of steps
;    axis_color : in, optional, type=color
;       color of axis, defaults to color of steps
;    _extra : in, optional, type=keywords
;       keywords to PLOT, OPLOT, or PLOTS
;-
pro mg_stepchart, x, y, overplot=overplot, $
                  thick=thick, riser_thick=riserThick, $
                  fill=fill, color=color, axis_color=axisColor, $
                  _extra=e
  compile_opt strictarr
  on_error, 2

  case n_params() of
    0: message, 'incorrect number of arguments'
    1: begin
        _x = findgen(n_elements(x))
        _y = x
      end
    2: begin
        _x = x
        _y = y
      end
  endcase

  _thick = n_elements(thick) gt 0L ? thick : 1.0
  _riserThick = n_elements(riserThick) gt 0L ? riserThick : 0.5 * _thick

  if (n_elements(axisColor) gt 0L) then _axisColor = axisColor

  n = n_elements(x)

  _x = reform(rebin(reform(_x, 1, n), 2, n), 2 * n)
  _y = reform(rebin(reform(_y, 1, n), 2, n), 2 * n)

  _x = _x[1:*]
  _y = _y[0: 2 * (n - 1)]

  if (keyword_set(overplot)) then begin
    if (_riserThick ne 0.) then oplot, _x, _y, thick=_riserThick, color=color, _extra=e
  endif else begin
    plot, [min(_x, max=_xmax), _xmax], [min(_y, max=_ymax), _ymax], $
          /nodata, color=_axisColor, _extra=e
  endelse

  mg_stepchart_plotflats, _x, _y, thick=_thick, fill=fill, color=color, _extra=e

  if (~keyword_set(overplot) && _riserThick gt 0.) then begin
    oplot, _x, _y, thick=_riserThick, color=color, _extra=e
  endif
end


; main-level example program

n = 30
seed = 12345

x = [0, 5 * randomu(seed, n - 1L)]
x = total(x, /cumulative)

d = randomu(seed, n)
for i = 0, 2 do d = smooth(d, 3, /edge_truncate)

if (keyword_set(ps)) then begin
  mg_psbegin, /image, filename='step.ps', xsize=8, ysize=3, /inches
endif else begin
  device, get_decomposed=dec
  device, decomposed=1
endelse

plot, x, d, /nodata, xrange=[0, max(x)], yticks=4, yrange=[0., 1.], ystyle=9, xstyle=9

if (keyword_set(ps)) then tvlct, 255, 0, 0, 255
mg_stepchart, x, d, thick=6, riser_thick=1, /overplot, color='0000ff'x

if (keyword_set(ps)) then begin
  mg_psend
  mg_convert, 'step', max_dimensions=[400, 400], output=im
  im = bytscl(im)
  tv, im, true=1
endif else device, decomposed=dec

end

; docformat = 'rst'

;+
; Wrapper for `PLOT` with better defaults.
;
; :Categories:
;    direct graphics
;-

;+
; Make sure that `!d` is set correctly.
;-
pro mg_plot_setdims
  compile_opt strictarr

  ; other devices besides a graphics window
  if (!d.name ne 'X' && !d.name ne 'WIN') then return

  ; existing graphics window
  if (!d.window ne -1L) then return

  window, /pixmap
  wdelete, !d.window
end


;+
; Wrapper for PLOT routine which has several differences:
;   1. removes top and right axis frames by default, but may be changed
;      through the `XSTYLE` or `YSTYLE` keywords
;   2. contracts limits of plot to exact x range
;
; :Params:
;    x : in, optional, type=1D numeric array
;       x values for plot, defaults just to findgen(n)
;    y : in, required, type=1D numeric array
;       y values for plot
;
; :Keywords:
;    slope_aspect : in, optional, type=boolean
;       set to make the average slope of line segments (on display) +/- 1
;    xstyle : in, optional, type=integer, default=9
;       `XSTYLE` keyword from `PLOT`
;    ystyle : in, optional, type=integer, default=9
;       `YSTYLE` keyword from `PLOT`
;    _extra : in, optional, type=keywords
;       keywords to `PLOT`
;-
pro mg_plot, x, y, slope_aspect=slopeAspect, xstyle=xstyle, ystyle=ystyle, _extra=e
  compile_opt strictarr
  on_error, 2

  _xstyle = n_elements(xstyle) eq 0L ? 9 : xstyle OR 9
  _ystyle = n_elements(ystyle) eq 0L ? 8 : ystyle OR 8

  if (n_params() eq 0L) then message, 'at least one parameter is required'

  mg_plot_setdims
  position = [!d.x_ch_size * !x.margin[0] / !d.x_size, $
              !d.y_ch_size * !y.margin[0] / !d.y_size, $
              (!d.x_size - !d.x_ch_size * !x.margin[1]) / !d.x_size, $
              (!d.y_size - !d.y_ch_size * !y.margin[1]) / !d.y_size]

  if (keyword_set(slopeAspect)) then begin
    meanAbsSlope = mean(abs(n_params() eq 1L ? deriv(x) : deriv(x, y)))

    ; size of plotting region in centimeters
    xsize = (position[2] - position[0]) * !d.x_size / !d.x_px_cm
    ysize = (position[3] - position[1]) * !d.y_size / !d.y_px_cm

    case n_params() of
      1: begin
          xrange = n_elements(x) - 1L
          yrange = max(x, min=ymin) - ymin
        end
      2: begin
          xrange = max(x, min=ymin) - ymin
          yrange = max(y, min=ymin) - ymin
        end
    endcase

    displaySlope = (ysize / yrange) / (xsize / xrange) * meanAbsSlope

    ; displaySlope > 1 then shrink y else shrink x
    if (displaySlope gt 1) then begin
      range = position[3] - position[1]
      center = (position[3] + position[1]) / 2.0
      range /= displaySlope
      position[1] = center - range / 2.0
      position[3] = center + range / 2.0
    endif else begin
      range = position[2] - position[0]
      center = (position[2] + position[0]) / 2.0
      range *= displaySlope
      position[0] = center - range / 2.0
      position[2] = center + range / 2.0
    endelse
  endif

  case n_params() of
    1: plot, x, xstyle=_xstyle, ystyle=_ystyle, position=position, _extra=e
    2: plot, x, y, xstyle=_xstyle, ystyle=_ystyle, position=position, _extra=e
  endcase
end

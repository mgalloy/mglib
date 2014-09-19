; docformat = 'rst'

;+
; Create a raster image of a set of lines.
;
; :Returns:
;   image array
;
; :Params:
;   x : in, required, type=numeric array
;     x-coordinates of line
;   y : in, required, type=numeric array
;     y-coordinates of line
;
; :Keywords:
;   polylines : in, optional, type=lonarr
;     polyline description of the lines in `x` and `y`; default is::
;
;       [n, lindgen(n)]
;
;     For each line in `POLYLINES`, there will be a section like::
;
;        [n1, ind1_0, ind1_1, ind1_n1, n2, ... ]
;
;   dimensions : in, optional, type=lonarr(2), default="[400, 400]"
;     size of raster output
;   xrange : in, optional, type=fltarr(2)
;     min/max of `x`
;   yrange : in, optional, type=fltarr(2)
;     min/max of `y`
;-
function mg_rasterpolyline, x, y, polylines=polylines, $
                            dimensions=dimensions, $
                            xrange=xrange, yrange=yrange
  compile_opt strictarr

  if (n_elements(xrange) gt 0L) then begin
    _xrange = xrange
  endif else begin
    maxx = max(x, min=minx)
    _xrange = [minx, maxx]
  endelse

  if (n_elements(yrange) gt 0L) then begin
    _yrange = yrange
  endif else begin
    maxy = max(y, min=miny)
    _yrange = [miny, maxy]
  endelse

  nx = n_elements(x)

  _dimensions = n_elements(dimensions) eq 0L ? [400L, 400L] : long(dimensions)
  _polylines = n_elements(polylines) eq 0L ? [nx, lindgen(nx)] : polylines

  result = mg_rasterpolyline_(x, y, _polylines, _dimensions, _xrange, _yrange)

  return, result
end

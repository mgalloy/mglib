; docformat = 'rst'

function vis_rasterpolyline, x, y, polylines=polylines, $
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

  result = vis_rasterpolyline_(x, y, _polylines, _dimensions, _xrange, _yrange)
  
  return, result
end

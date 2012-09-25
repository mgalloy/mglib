; docformat = 'rst'

;+
; Display a 3-dimensional scatter plot.
; 
; :Categories:
;    direct graphics
;-


;+
; Display a 3-dimensional scatter plot.
;
; :Params:
;    x :  in, required, type=fltarr
;       x-values of data
;    y :  in, required, type=fltarr
;       y-values of data
;    z :  in, required, type=fltarr
;       z-values of data
;
; :Keywords:
;    _extra : in, optional, type=keywords
;       graphics keywords to SURFACE and PLOTS
;-
pro mg_scatter3d, x, y, z, _extra=e
  compile_opt strictarr
  on_error, 2
  
  nx = n_elements(x)
  ny = n_elements(y)
  nz = n_elements(z)
  
  zrange = [min(z, max=zmax), zmax]
  
  if (nx ne ny || ny ne nz) then begin
    message, 'x, y, and z arrays must have same number of elements'
  endif
  
  ; create axis and coordinate system
  surface, fltarr(nx, ny), x, y, /nodata, /save, $
           zrange=zrange, _extra=e
  
  plots, x, y, z, /t3d, _extra=e
  
  for p = 0L, nz - 1L do begin
    plots, [x[p], x[p]], [y[p], y[p]], [zrange[0], z[p]], /t3d
  endfor
end


x = replicate(5., 10.)  
x1 = cos(findgen(36) * 10. * !dtor) * 2. + 5.  
x = [x, x1, x]  
y = findgen(56)  
z = replicate(5., 10)  
z1 = sin(findgen(36) * 10. * !dtor) * 2. + 5.  
z = [z, z1, z]

mg_scatter3d, x, y, z, charsize=2.0

end
; docformat = 'rst'

;+
; Make streamline plots of 2D vector fields.
;
; :Categories:
;    direct graphics, flow
;
; :Examples:
;   See the main-level program part of this file for the details of creating
;   the below visualizations. To use a list of random starting points use
;   something like::
;
;      IDL> restore, filepath('globalwinds.dat', subdir=['examples','data'])
;      IDL> mg_vel, u, v, nvecs=800
;
;   This produces the following (although the following has been enhanced by
;   creating PostScript output and converted to an image with `MG_CONVERT`):
; 
;   .. image:: vel-random.png
;
;   To use a grid of slightly jittered starting points use something like::
;
;      IDL> mg_vel, u, v, /grid, stride=3, jitter=0.5
;
;   This produces the following (again enhanced with `MG_CONVERT`):
;
;   .. image:: vel-jittergrid.png
;-

;+
; Bilinear interpolation.
;
; :Returns:
;    fltarr(m * n)
; 
; :Params:
;    a : in, required, type="fltarr(m, n)"
;       vector
;    x : in, required, type=fltarr(m * n)
;       x coords
;    y : in, required, type=fltarr(m * n)
;       y coords
;-
function mg_vel_interpolate, a, x, y
  compile_opt idl2, hidden
  on_error, 2   

  sa = size(a, /dimensions)
  nx = sa[0]
  
  i = long(x) + nx * long(y)

  p = x - long(x)
  q = y - long(y)

  p1 = 1. - p
  q1 = 1. - q

  res = p1 * q1 * a[i] $
           + p * q1 * a[i + 1] $
           + q * p1 * a[i + nx] $
           + p * q * a[i + nx + 1]
  
  return, res
end


;+
; Add the heads to the arrows.
; 
; :Params:
;    s : in, out, required, type=fltarr
;       array of streamlines
;-
pro mg_vel_arrowhead, s
  compile_opt idl2, hidden
  on_error, 2

  theta = 30.0 * !radeg   ; arrowhead angle
  tant = tan(theta)
  np = 3.0
  scale = 8.

  ss = size(s, /dimensions)
  n = ss[1]

  ; find vectors whose last segment has zero length
  xlastlen = s[*, n - 4, 0] - s[*, n - 5, 0]
  ylastlen = s[*, n - 4, 1] - s[*, n - 5, 1]
  lastlen = sqrt(xlastlen^2 + ylastlen^2)  
  whereLastlenZero = where(lastlen eq 0.0, nzero, complement=whereLastlenNotZero)
  
  len  = scale * tant * lastlen[whereLastlenNotZero] / np

  dx = len * (s[whereLastlenNotZero, n - 4, 1] $
         - s[whereLastlenNotZero, n - 5, 1]) / lastlen[whereLastlenNotZero]
  dy = len * (s[whereLastlenNotZero, n - 4, 0] $
         - s[whereLastlenNotZero, n - 5, 0]) / lastlen[whereLastlenNotZero]

  xm = s[whereLastlenNotZero, n - 4, 0] $
         - (scale - 1) * (s[whereLastlenNotZero, n - 4, 0] $
         - s[whereLastlenNotZero, n - 5, 0]) / np
  ym = s[whereLastlenNotZero, n - 4 , 1] $
         - (scale - 1) * (s[whereLastlenNotZero, n - 4, 1] $
         - s[whereLastlenNotZero, n - 5, 1]) / np

  s[whereLastlenNotZero, n - 3, 0] = xm - dx
  s[whereLastlenNotZero, n - 2, 0] = s[whereLastlenNotZero, n - 4, 0]
  s[whereLastlenNotZero, n - 1, 0] = xm + dx

  s[whereLastlenNotZero, n - 3, 1] = ym + dy
  s[whereLastlenNotZero, n - 2, 1] = s[whereLastlenNotZero, n - 4, 1]
  s[whereLastlenNotZero, n - 1, 1] = ym - dy

  ; no head for 0 length
  if (nzero ge 1) then begin  
    s[whereLastlenZero, n - 3, 0] = s[whereLastlenZero, n - 4, 0]
    s[whereLastlenZero, n - 2, 0] = s[whereLastlenZero, n - 4, 0]
    s[whereLastlenZero, n - 1, 0] = s[whereLastlenZero, n - 4, 0]

    s[whereLastlenZero, n - 3, 1] = s[whereLastlenZero, n - 4, 1]
    s[whereLastlenZero, n - 2, 1] = s[whereLastlenZero, n - 4, 1]
    s[whereLastlenZero, n - 1, 1] = s[whereLastlenZero, n - 4, 1]
  endif

  return
end


;+
; Compute the streamlines from each starting point.
;
; :Returns:
;    fltarr(mvecs, nsteps + 3, 2)
;
; :Params:
;    u : in, required, type="fltarr(m, n)"
;       x component at each point of the vector field; must be a 2D array
;    v : in, required, type="fltarr(m, n)"  
;       y component at each point of the vector field; must be a 2D array
;
; :Keywords:
;    nvecs : in, out, required, type=long
;       number of steps in the streamline
;    nsteps : in, required, type=long
;       number of steps in each streamline
;    length : in, required, type=fltarr
;       scaling factor for the length of the streamlines
;    grid : in, optional, type=boolean
;       set to jitter a regular grid of starting points instead of choosing
;       completely random starting points
;    stride : in, optional, type=long, default=1L
;       stride amount through grid; only used if GRID is set
;    jitter : in, optional, type=float, default=0.5
;       amount to jitter elements in the grid; as a fraction of the distance
;       between grid elements
;-
function mg_vel_streamlines, u, v, $
                             nvecs=nvecs, length=length, nsteps=nsteps, $
                             grid=grid, stride=stride, jitter=jitter
  compile_opt idl2, hidden
  on_error, 2

  su = size(u, /dimensions)
  nx = su[0]
  ny = su[1]

  maxlen = sqrt(max(u^2 + v^2, /nan))   ; max vector length
  dt = 1. * length / maxlen /nsteps
  
  if (keyword_set(grid)) then begin
    ; set sizes, accounting for stride
    _nx = nx / stride
    _ny = ny / stride
    nvecs = _nx * _ny

    ; create grid
    xt = reform(findgen(_nx) # (fltarr(_ny) + 1.0) / (_nx - 1L), _nx * _ny)
    yt = reform((fltarr(_nx) + 1.0) # findgen(_ny) / (_ny - 1L), _nx * _ny)
    
    ; create jittter
    xjitter = randomu(seed, _nx * _ny)
    yjitter = randomu(seed, _nx * _ny)    
    
    ; add jitter to grid
    xt += jitter * xjitter / (_nx - 1L)
    yt += jitter * yjitter / (_ny - 1L)   
  endif else begin
    xt = randomu(seed, nvecs)
    yt = randomu(seed, nvecs)
  endelse
  
  ; vectors, steps + arrow, components (x and y)
  s = fltarr(nvecs, nsteps + 3, 2)
  
  ; initial streamlines are the starting points
  s[0, 0, 0] = xt
  s[0, 0, 1] = yt
  
  ; add a segment to the streamlines each loop through
  for i = 1L, nsteps - 1L do begin
    xt[0] = (nx - 1L) * s[*, i - 1L, 0L]
    yt[0] = (ny - 1L) * s[*, i - 1L, 1L]
    
    ut = mg_vel_interpolate(u, xt, yt)
    vt = mg_vel_interpolate(v, xt, yt)
    
    ; go from last step
    s[0L, i, 0L] = s[*, i - 1L, 0L] + ut * dt
    s[0L, i, 1L] = s[*, i - 1L, 1L] + vt * dt
  end
  
  ; add the arrowheads
  mg_vel_arrowhead, s
  
  return, s < 1.0 > 0.0   ; must between 0.0 and 1.0
end


;+
; Draw a velocity (flow) field with streamlines following the field 
; proportional in length to the vector field magnitude.
; 
; A random number of starting points can be picked (with NVECS=n) or a grid
; of starting points jittered slightly to eliminate linear patterns (with 
; /GRID, STRIDE=3, and JITTER=jit).
;
; NVECS random points within the (u,v) arrays are selected.
; For each "shot" the field (as bilinearly interpolated) at each
; point is followed using a vector of LENGTH length, tracing
; a line with NSTEPS segments.  An arrow head is drawn at the end.
;
; :Params:
;    u : in, required, type="fltarr(m, n)"
;       x component at each point of the vector field; must be a 2D array
;    v : in, required, type="fltarr(m, n)"  
;       y component at each point of the vector field; must be a 2D array
;    x : in, optional, type=fltarr(m)
;       x axis values
;    y : in, optional, type=fltarr(n)
;       y axis values
;
; :Keywords:
;    overplot : in, optional, type=boolean
;       set to not erase current display before making plot
;    nvecs : in, optional, type=long, default=200L
;       number of vectors (arrows) to draw 
;    length : in, optional, type=float, default=0.1
;       the length of each arrow line segment expressed as a fraction of the 
;       longest vector divided by the number of steps
;    nsteps : in, optional, type=long, default=10L 
;       number of shoots or line segments for each arrow
;    grid : in, optional, type=boolean
;       set to jitter a regular grid of starting points instead of choosing
;       completely random starting points
;    stride : in, optional, type=long, default=1L
;       stride amount through grid; only used if GRID is set
;    jitter : in, optional, type=float, default=0.5
;       amount to jitter elements in the grid; as a fraction of the distance
;       between grid elements
;    max_thick : in, optional, type=float, default=3.0
;       maximum thickness to use for streamlines; ignored if THICK keyword is 
;       present
;    thick : in, optional, type=float, default=1.0
;       set to a constant to use that thickness for streamlines instead of
;       thicknesses set to values proportional to the magnitude of the 
;       vector field at the point of the beginning of the streamline
;    color : in, optional, type=color
;       color of streamlines
;    axes_color : in, optional, type=color
;       color of axes
;    xmax : in, optional, type=float, default=1.0
;       ignored; only present to implement the interface of VEL
;    streamlines : out, optional, type=fltarr
;       calculated streamlines; no graphics output is done if a named variable
;       is passed to this keyword
;    _extra : in, optional, type=keywords
;       keywords to PLOT and PLOTS routines that plot the streamlines
;-
pro mg_vel, u, v, x, y, $
            overplot=overplot, $
            nvecs=nvecs, length=length, nsteps=nsteps, xmax=xmax, $
            grid=grid, stride=stride, jitter=jitter, thick=thick, $
            max_thick=maxThick, color=color, axes_color=axesColor, $
            streamlines=s, $
            _extra=e
  compile_opt idl2
  on_error, 2

  _nvecs = n_elements(nvecs) eq 0L ? 200L : nvecs
  _nsteps = n_elements(nsteps) eq 0L ? 10L : nsteps
  _length = n_elements(length) eq 0L ? 0.1 : length
  _stride = n_elements(stride) eq 0L ? 1L : stride
  _jitter = n_elements(jitter) eq 0L ? 0.5 : jitter
  _maxThick = n_elements(maxThick) eq 0L ? 3.0 : maxThick

  _u = reform(u)
  _v = reform(v)
  
  if (n_elements(xmax) gt 0L) then begin
    message, 'XMAX keyword obsolete', /informational
  endif
  
  su = size(_u, /structure)
  sv = size(_v, /structure)
  
  if ((su.n_dimensions ne 2) or (sv.n_dimensions ne 2)) then begin
    message, 'U, V must be 2-dimensional arrays'
    return
  endif

  ; compute streamlines
  if (_nvecs gt 0) then begin
    s = mg_vel_streamlines(_u, _v, $
                           nvecs=_nvecs, length=_length, nsteps=_nsteps, $
                           grid=grid, stride=_stride, jitter=_jitter)
  endif
  
  if (arg_present(s)) then return
  
  _x = n_elements(x) eq 0L ? findgen(su.dimensions[0]) : x
  _y = n_elements(y) eq 0L ? findgen(su.dimensions[1]) : y
  xmin = min(_x, max=xmax)
  ymin = min(_y, max=ymax)
  
  ; setup coordinate system
  if (~keyword_set(overplot)) then begin
    plot, [xmin, xmax, xmax, xmin, xmin], $
          [ymin, ymin, ymax, ymax, ymin], $
          /nodata, $
          color=n_elements(color) eq 0L $
                  ? (!d.name eq 'PS' $
                      ? 0 $
                      : (n_elements(axesColor) eq 0L ? 'FFFFFF'x : axesColor)) $
                  : color, $
          _extra=e
  endif
  
  mag = alog10(sqrt(_u^2 + _v^2))
  maxmag = max(mag)

  ; write each streamline
  for i = 0L, _nvecs - 1L do begin
    smag = mag[(su.dimensions[0] - 1) * s[i, 0, 0], $
               (su.dimensions[1] - 1) * s[i, 0, 1]] / maxmag
    _thick = n_elements(thick) eq 0L ? _maxThick * smag : thick
    _color = n_elements(color) eq 0L $
               ? (!d.name eq 'PS' $
                    ? byte(255 * smag) $
                    : mg_rgb2index(bytarr(3) + byte(255 * smag))) $
               : color
    plots, (xmax - xmin) * s[i, *, 0] + xmin, $
           (ymax - ymin) * s[i, *, 1] + ymin, $
           thick=_thick, $
           clip=[!x.crange[0], !y.crange[0], !x.crange[1], !y.crange[1]], $
           noclip=0, $
           color=_color, $
           _extra=e
  endfor
end


; example code

restore, filepath('globalwinds.dat', subdir=['examples','data'])

device, get_decomposed=odec
device, decomposed=0

mg_loadct, 11, /brewer
tvlct, r, g, b, /get
r[0] = 255
g[0] = 255
b[0] = 255
r[255] = 0
g[255] = 0
b[255] = 0
tvlct, r, g, b

window, /free, title='Global winds - random vectors', xsize=500, ysize=300
mg_vel, u, v, x, y, nvecs=800, $
        max_thick=2.0, $
        xstyle=1, ystyle=1, $
        xticks=4, xtickv=[-180, -90, 0, 90, 180], $
        yticks=4, ytickv=[-90, -45, 0, 45, 90]

mg_loadct, 17, /brewer
tvlct, r, g, b, /get
r[0] = 255
g[0] = 255
b[0] = 255
r[255] = 0
g[255] = 0
b[255] = 0
tvlct, r, g, b

window, /free, title='Global winds - jittered grid', xsize=500, ysize=300
mg_vel, u, v, x, y, $
        /grid, stride=3, jitter=0.75, $
        max_thick=2.1, $         
        xstyle=1, ystyle=1, $
        xticks=4, xtickv=[-180, -90, 0, 90, 180], $
        yticks=4, ytickv=[-90, -45, 0, 45, 90]

device, decomposed=odec

end
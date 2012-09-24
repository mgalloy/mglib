; docformat = 'rst'

;+
; This function simplifies the vertices of an `n`-dimenstional polyline. 
; Vertices are removed if they are within a tolerance tangential distance from
; an approximating line segment.
;
; :Examples:
;    See the main-level program at the end of this file for some examples. To
;    run them, type::
;
;       IDL> .run mg_polyline_simplify
;
; :History:
;   Original written by: Brad Gom, April 2004
;   Modified by Michael Galloy, 2010
;-


; helper routines

;+
; Computes the dot product.
;
; :Returns:
;    float
; 
; :Params:
;    x : in, required, type=vector
;      first parameter
;    y : in, required, type=vector
;      first parameter
;-
function mg_polyline_simplify_dot, x, y
  compile_opt strictarr
  
  return, total(x * y)
end


;+
; Computes the distance squared of difference between points x and y
;
; :Returns:
;    float
; 
; :Params:
;    x : in, required, type=fltarr(2)
;       first point
;    y : in, required, type=fltarr(2)
;       second point
;-
function mg_polyline_simplify_d2, x, y
  compile_opt strictarr
  
  diff = x - y
  return, total(diff * diff)
end


;+
; This is the Douglas-Peucker recursive simplification routine. It marks 
; vertices that are part of the simplified polyline for approximating the 
; polyline subchain `vertices[j]` to `vertices[k]`.
;
; :Params:
;    tol2 : in, required, type=float
;       approximation tolerance squared
;    vertices : in, required, type="fltarr(m, n)"
;       polyline array of vertex points
;    j : in, required, type=long
;       starting index fo subchain
;    k : in, required, type=long
;       ending index fo subchain
;    mk : in, out, required, type=bytarr(n)
;       array of markers matching vertex array `vertices`
;-
pro mg_polyline_simplify_dp, tol2, vertices, j, k, mk
  compile_opt strictarr
  
  if (k le j + 1L) then return ; there is nothing to simplify

  ; check for adequate approximation by segment s from vertices[j] to 
  ; vertices[k]
  maxi = j ; index of vertex farthest from s
  maxd2 = 0. ; distance squared of farthest vertex
  s = [[vertices[*, j]], [vertices[*, k]]]  ; segment from vertices[j] to vertices[k]
  u = s[*, 1L] - s[*, 0L]  ; segment direction vector
  cu = mg_polyline_simplify_dot(u, u)  ; segment length squared

  for i = j + 1L, k - 1L do begin
    ; compute distance squared
    w = vertices[*, i] - s[*, 0L]
    cw = mg_polyline_simplify_dot(w, u)
    if (cw le 0.) then begin
      ; dv2 = distance vertices[i] to s squared
      dv2 = mg_polyline_simplify_d2(vertices[*, i], s[*, 0L])
      endif else begin
      if (cu le cw) then begin
        dv2 = mg_polyline_simplify_d2(vertices[*, i], s[*, 1L])
      endif else begin
        b = cw / cu
        pb = s[*, 0L] + b * u ; base of perpendicular from vertices[i] to s
        dv2 = mg_polyline_simplify_d2(vertices[*, i], pb)
      endelse
    endelse
      
    ; test with current max distance squared
    if (dv2 le maxd2) then continue
    
    ; vertices[i] is a new max vertex
    maxi = i
    maxd2 = dv2
  endfor

  if (maxd2 gt tol2) then begin ; error is worse than the tolerance
    ; split the polyline at the farthest vertex from s
    mk[maxi] = 1B  ; mark vertices[maxi] for the simplified polyline
    
    ; recursively simplify the two subpolylines at vertices[*, maxi]
    
    ; vertices[j] to vertices[maxi]
    mg_polyline_simplify_dp, tol2, vertices, j, maxi, mk 
    ; vertices[maxi] to vertices[k]
    mg_polyline_simplify_dp, tol2, vertices, maxi, k, mk 
  endif
  ; else the approximation is OK, so ignore intermediate vertices
  
  return
end


;+
;
; `VIS_POLYLINE_SIMPLIFY` uses the Douglas-Peucker (DP) approximation 
; algorithm that is used extensively for both computer graphics and geographic
; information systems. See `geometryalgorithms.com <geometryalgorithms.com>`.
;
; :Params:
;    vertices : in, required, type="fltarr(m, n)"
;       An array of vertices representing the polyline. Must be a [m, n] 
;       array, where `m` is the dimensionality and `n` is the number of 
;       vertices. Both `m > 1` and `n > 1` are required.
;
; :Keywords:
;    tolerance : in, optional, type=float
;       Set this keyword to the tolerance value to use. If `tolerance` is not
;       set, or set to a negative or zero value, then the tolerance will be 
;       set automatically to the minimum average spacing along any dimension 
;       between points.
;
;       Choice of tolerance is key to the amount of simplification. The 
;       routine approximates the polyline with line segments that are no 
;       further than tolerance from any vertices. Vertices that are within 
;       tolerance from the approximating lines are removed. If no tolerance is 
;       specified, the routine uses the minimum distance in each dimension 
;       between vertices, and multiplies this by `factor` as a tolerance.
;
;    factor : in, optional, type=float, default=1. 
;       Set this keyword instead of `tolerance` to scale the automatic 
;       tolerance. For example, `FACTOR=10` will use 10x the minimum average
;       spacing between points as the tolerance. Ignored if `tolerance` is 
;       set.
;
; :Returns:
;    This function returns the simplified array of vertices. If an error
;    occurs, the output vertices will all be -1L.
;-
function mg_polyline_simplify, vertices, tolerance=tolerance, factor=factor
  compile_opt strictarr
  
  _factor = n_elements(factor) eq 0L ? 1. : factor
    
  ; don't do any simplification if factor is 0 or -ve
  if (_factor lt 1.) then return, vertices

  ; vertices is a 2 or 3 (or more) by n array
  dim = size(vertices, /dimensions)
  n = dim[1]  ; number of points
  if (dim[0] lt 2L) then begin
    message, 'vertices must be at least 2-dimensional', /continue
    return, vertices * 0L - 1L
  endif

  if (n lt 2L) then begin
    message, 'there must be at least 2 vertices', /continue
    return, vertices * 0L - 1L
  endif

  _tolerance = n_elements(tolerance) eq 0L ? 0. : tolerance

  if (_tolerance le 0.) then begin  ; automatically set tolerance
    diff = abs((vertices - shift(vertices, 0, 1))[*, 1:*])
    
    ; minimum distance in x or y between adjacent points
    inds = where(diff ne 0., count)
    if (count eq 0L) then begin
      message, 'vertices have no unique points', /continue
      return, vertices * 0L - 1L
    endif
    
    ; tolerance is the minimum difference in x or y beteween adjacent points 
    ; times the factor
    _tolerance = min(diff[inds]) * _factor
  endif

  vt = vertices * 0L ;  vertex buffer
  mk = bytarr(n)  ;  marker buffer

  ; stage 1: vertex reduction within tolerance of prior vertex cluster
  vt[*, 0L] = vertices[*, 0L]   ; start at the beginning
  k = 1L
  pv = 0L
  tol2 = _tolerance * _tolerance
  for i = 1L, n - 1L do begin
    if (mg_polyline_simplify_d2(vertices[*, i], vertices[*, pv]) lt tol2) then continue
    vt[*, k++] = vertices[*, i]
    pv = i
  endfor

  if (pv lt n - 1L) then vt[*, k++] = vertices[*, n - 1L] ; finish at the end

  ; stage 2: Douglas-Peucker polyline simplification
  
  ; Mark vertices that will be in the simplified polyline:
  ;   - step 1: initially mark v0 and vn
  ;   - step 2: recursively simplify by selecting vertex furthest away
  
  ; mark the first and last vertices
  mk[0L] = 1B
  mk[k - 1L] = 1B 

  mg_polyline_simplify_dp, tol2, vt, 0L, k - 1L, mk

  return, vt[*, where(mk)] ; return simplified polyline
end


; main-level example program

mg_decomposed, 0, old_decomposed=oldDecomposed

red   = [0, 220, 255, 255, 255,   0,   0, 255, 160, 255]
green = [0, 140,   0, 127, 255, 255,   0,   0, 160, 255]
blue  = [0, 127,   0,   0,   0,   0, 255, 255, 160, 255]
tvlct, red, green, blue

x = findgen(500)
y = sin(x / 100. * 30.) / 5. + sin(x / 1000. * 30.)

vertices = transpose([[x], [y]])

window, 0, xsize=1000, ysize=700
plot, [min(x),max(x)], [min(y),max(y)], /nodata
plots, vertices, color=9

; choice of tolerance is key to the amount of simplification. The routine
; approximates the polyline with line segments that are no further than
; tolerance from any vertices. Vertices that are within tolerance from the
; approximating lines are removed. If no tolerance is specified, the
; routine uses the minimum distance in each dimension between vertices, and
; multiplies this by 'factor' as a tolerance.

; distance between adjacent points
d = (sqrt(total((vertices - shift(vertices, 0, 1))^2, 1)))[1:*]
; this doesn't work so well if the scale of one dimension is much larger than 
; another

; minimum distance in x or y.. between adjacent points
dmin = min(abs((vertices - shift(vertices, 0, 1))[*, 1:*]))

; avg distance in x or y between points, whichever is smaller
dx_average = (moment(abs((vertices - shift(vertices, 0, 1))[0, 1:*])))[0]
dy_average = (moment(abs((vertices - shift(vertices, 0, 1))[1, 1:*])))[0]
davg = dx_average < dy_average

factor = 100L
n = 1L

t = systime(/seconds)
for i = 0L, n - 1L do a = mg_polyline_simplify(vertices, tolerance=dmin)
ta = systime(/seconds) - t

t = systime(/seconds)
for i = 0L, n - 1L do b = mg_polyline_simplify(vertices, tolerance=davg)
tb = systime(/seconds) - t
  
t = systime(/seconds)
for i=0,n-1 do c = mg_polyline_simplify(vertices, factor=factor)
tc = systime(/seconds) - t

t = systime(/seconds)

print, n_elements(vertices) / 2, $
       format='(%"Original number of output vertices: %d")'

wait, 2.
print, dmin, $
       format='(%"RED: After simplifying with tolerance: %f (minimum distance in x or y)")'
print, n_elements(a) / 2, strtrim(ta / n), $       
       format='(%" number of output vertices: %d\n time: %f")'
plots, a, psym=-4, color=2

wait, 2.
print, davg, $
       format='(%"GREEN: After simplifying with tolerance: %f (lesser of the average distace in x or y)")'
print, n_elements(b) / 2, strtrim(tb / n), $
       format='(%" number of output vertices: %d\n time: %f")'
plots, b, psym=-4, color=5

wait, 2.
print, factor, $
       format='(%"BLUE:  After simplifying with factor: %d")'
print, n_elements(c) / 2, strtrim(tc / n), $
       format='(%" number of output vertices: %d\n time: %f")'
plots, c, psym=-4, color=6

mg_decomposed, oldDecomposed

end
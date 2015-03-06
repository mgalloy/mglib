; docformat = 'rst'

;+
; Function to use coefficients from surf_fit and create polynomial
; surface.
;
; Evaluates the surface:
;
;   $$F(x, y) = \sum_{i=0}^{d_x - 1} \sum_{j=0}^{d_y - 1} c_{i, j} x^i y^j$$
;
; in a 2-dimensional array for the given `x` and `y` coordinates.
;
; :Returns:
;   `fltarr(nx, ny)`
;
; :Params:
;   coeff : in, required, type="fltarr(degree_x, degree_y)"
;     coefficients
;   coord_x : in, required, type=fltarr(nx)
;     x-coordinates
;   coord_y : in, required, type=fltarr(ny)
;     y-coordinates
;-
function mg_eval_surface, coeff, coord_x, coord_y
  compile_opt strictarr

  degrees = size(coeff, /dimensions)
  nx = n_elements(coord_x)
  ny = n_elements(coord_y)

  x = rebin(reform(coord_x), nx, degrees[0])
  x ^= rebin(lindgen(1, degrees[0]), nx, degrees[0])
  y = rebin(reform(coord_y), ny, degrees[1])
  y ^= rebin(lindgen(1, degrees[1]), ny, degrees[1])

  return, x # coeff # transpose(y)
end

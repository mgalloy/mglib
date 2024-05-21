; docformat = 'rst'

;+
; Convert Lab colors to XYZ.
;
; :Returns:
;   `fltarr(n_colors, 3)`
;
; :Params:
;   lab : in, required, type="fltarr(3)/fltarr(n_colors, 3)"
;     Lab colors
;-
function mg_lab2xyz, lab
  compile_opt strictarr

  ref_x = 95.047   ; Observer = 2 degree, Illuminant= D65
  ref_y = 100.000
  ref_z = 108.883

  n_dims = size(lab, /n_dimensions)
  L = n_dims eq 2 ? lab[*, 0] : lab[0]
  a = n_dims eq 2 ? lab[*, 1] : lab[1]
  b = n_dims eq 2 ? lab[*, 2] : lab[2]

  y = (L + 16.0) / 116.0
  x = a / 500.0 + y
  z = y - b / 200.0

  x_mask = x^3 gt 0.008856
  x = x_mask * x^3 + (1B - x_mask) * (x - 16.0 / 116.0) / 7.787

  y_mask = y^3 gt 0.008856
  y = y_mask * y^3 + (1B - y_mask) * (y - 16.0 / 116.0) / 7.787

  z_mask = z^3 gt 0.008856
  z = z_mask * z^3 + (1B - z_mask) * (z - 16.0 / 116.0) / 7.787

  x *= ref_x
  y *= ref_y
  z *= ref_z

  return, n_dims eq 2 ? [[x], [y], [z]] : [x, y, z]
end

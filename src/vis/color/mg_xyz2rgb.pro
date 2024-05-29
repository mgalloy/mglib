; docformat = 'rst'

;+
; Convert XYZ colors to RGB.
;
; :Returns:
;   `bytarr(n_colors, 3)`
;
; :Params:
;   xyz : in, required, type="fltarr(3)/fltarr(n_colors, 3)"
;     XYZ colors
;-
function mg_xyz2rgb, xyz
  compile_opt strictarr

  n_dims = size(xyz, /n_dimensions)
  x = n_dims eq 2 ? xyz[*, 0] : xyz[0]
  y = n_dims eq 2 ? xyz[*, 1] : xyz[1]
  z = n_dims eq 2 ? xyz[*, 2] : xyz[2]

  x /= 100.0
  y /= 100.0
  z /= 100.0

  r = x * 3.2406  + y * (-1.5372) + z * (-0.4986)
  g = x * (-0.9689) + y * 1.8758  + z * 0.0415
  b = x * 0.0557  + y * (-0.2040) + z * 1.0570

  r_mask = r gt 0.0031308
  r = r_mask * (1.055 * r ^ (1.0 / 2.4) - 0.055) + (1B - r_mask) * (12.92 * r)

  g_mask = g gt 0.0031308
  g = g_mask * (1.055 * g ^ (1.0 / 2.4) - 0.055) + (1B - g_mask) * (12.92 * g)

  b_mask = b gt 0.0031308
  b = b_mask * (1.055 * b ^ (1.0 / 2.4) - 0.055) + (1B - b_mask) * (12.92 * b)

  r = byte(0 > round(255.0 * r) < 255)
  g = byte(0 > round(255.0 * g) < 255)
  b = byte(0 > round(255.0 * b) < 255)

  return, n_dims eq 2 ? [[r], [g], [b]] : [r, g, b]
end

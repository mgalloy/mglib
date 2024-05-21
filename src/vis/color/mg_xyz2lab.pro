; docformat = 'rst'

function mg_xyz2lab, xyz
  compile_opt strictarr

  ref_x = 95.047   ; Observer = 2 degree, Illuminant= D65
  ref_y = 100.000
  ref_z = 108.883

  n_dims = size(xyz, /n_dimensions)
  x = n_dims eq 2 ? xyz[*, 0] : xyz[0]
  y = n_dims eq 2 ? xyz[*, 1] : xyz[1]
  z = n_dims eq 2 ? xyz[*, 2] : xyz[2]

  x /= ref_x
  y /= ref_y
  z /= ref_z

  x_mask = x gt 0.008856
  x = x_mask * x^(1.0 / 3.0) + (1B - x_mask) * (7.787 * x + 16.0 / 116.0)

  y_mask = y gt 0.008856
  y = y_mask * y^(1.0 / 3.0) + (1B - y_mask) * (7.787 * y + 16.0 / 116.0)

  z_mask = z gt 0.008856
  z = z_mask * z^(1.0 / 3.0) + (1B - z_mask) * (7.787 * z + 16.0 / 116.0)

  L = (116.0 * y) - 16.0
  a = 500.0 * (x - y)
  b = 200.0 * (y - z)

  return, n_dims eq 2 ? [[L], [a], [b]] : [L, a, b]
end

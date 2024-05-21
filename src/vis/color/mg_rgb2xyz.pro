; docformat = 'rst'

;+
; Convert RGB colors to XYZ.
;
; :Returns:
;   `fltarr(n_colors, 3)`
;
; :Params:
;   rgb : in, required, type="bytarr(3)/bytarr(n_colors, 3)"
;     RGB colors
;-
function mg_rgb2xyz, rgb
  compile_opt strictarr

  n_dims = size(rgb, /n_dimensions)
  r = n_dims eq 2 ? rgb[*, 0] : rgb[0]
  g = n_dims eq 2 ? rgb[*, 1] : rgb[1]
  b = n_dims eq 2 ? rgb[*, 2] : rgb[2]

  r /= 255.0
  g /= 255.0
  b /= 255.0

  r_mask = r gt 0.04045
  r = r_mask * ((r + 0.055) / 1.055)^2.4 + (1B - r_mask) * (r / 12.92)

  g_mask = g gt 0.04045
  g = g_mask * ((g + 0.055) / 1.055)^2.4 + (1B - g_mask) * (g / 12.92)

  b_mask = b gt 0.04045
  b = b_mask * ((b + 0.055) / 1.055)^2.4 + (1B - b_mask) * (b / 12.92)

  r *= 100.0
  g *= 100.0
  b *= 100.0

  ; Observer = 2 degrees, Illuminant = D65
  x = r * 0.4124 + g * 0.3576 + b * 0.1805
  y = r * 0.2126 + g * 0.7152 + b * 0.0722
  z = r * 0.0193 + g * 0.1192 + b * 0.9505

  return, n_dims eq 2 ? [[x], [y], [z]] : [x, y, z]
end

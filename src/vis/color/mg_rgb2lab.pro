; docformat = 'rst'

;+
; Convert RGB colors to Lab.
;
; :Returns:
;   `fltarr(n_colors, 3)`
;
; :Params:
;   rgb : in, required, type="bytarr(3)/bytarr(n_colors, 3)"
;     RGB colors
;-
function mg_rgb2lab, rgb
  compile_opt strictarr

  xyz = mg_rgb2xyz(rgb)
  lab = mg_xyz2lab(xyz)

  return, lab
end

; docformat = 'rst'

;+
; Convert Lab colors to RGB.
;
; :Returns:
;   `bytarr(n_colors, 3)`
;
; :Params:
;   lab : in, required, type="fltarr(3)/fltarr(n_colors, 3)"
;     Lab colors
;-
function mg_lab2rgb, lab
  compile_opt strictarr

  xyz = mg_lab2xyz(lab)
  rgb = mg_xyz2rgb(xyz)

  return, rgb
end

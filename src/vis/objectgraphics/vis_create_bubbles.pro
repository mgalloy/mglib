; docformat = 'rst'

;+
; Factory function to create an array of bubbles.
;
; :Params:
;    x : in, required, type=fltarr
;       x-coordinates of bubbles to create
;    y : in, required, type=fltarr
;       y-coordinates of bubbles to create
;
; :Keywords:
;    sizes : in, optional, type=float/fltarr
;       sizes of bubbles to cycle through; size of radius unless AREA is set,
;       in which case it is the size of the area of the bubble
;    area : in, optional, type=boolean
;       set to specify SIZES as areas instead of radii
;    colors : in, optional, type=bytarr
;       colors to cycle through, can be a 1-dimensional array of indices or
;       2-dimensional (i.e., m x 3) array of RGB color values
;    border_colors : in, optional, type=bytarr
;       colors to cycle through for the bubble border, can be a 1-dimensional 
;       array of indices or 2-dimensional (i.e., m x 3) array of RGB color 
;       values
;    _extra : in, optional, type=keywords
;       keywords to VISgrBubble::init
;-
function vis_create_bubbles, x, y, sizes=sizes, area=area, $
                             colors=colors, border_colors=borderColors, $
                             _extra=e
  compile_opt strictarr

  n = n_elements(x)
  
  _sizes = n_elements(sizes) eq 0L ? 1.0 : sizes
  _colors = n_elements(colors) eq 0L ? 0B : colors
  _borderColors = n_elements(borderColors) eq 0L ? 0B : borderColors
  
  nsizes = n_elements(_sizes)

  colors_dims = size(_colors, /dimensions)
  colors_ndims = size(_colors, /n_dimensions)
  ncolors = colors_dims[0]

  border_colors_dims = size(_borderColors, /dimensions)
  border_colors_ndims = size(_borderColors, /n_dimensions)
  nbordercolors = border_colors_dims[0]
  
  arr = objarr(n)
  for b = 0L, n - 1L do begin
    bubble_color = colors_ndims eq 2L $
                     ? reform(_colors[b mod ncolors, *]) $
                     : _colors[b mod ncolors]
    border_color = border_colors_ndims eq 2L $
                     ? reform(_borderColors[b mod ncolors, *]) $
                     : _borderColors[b mod nbordercolors]
    arr[b] = obj_new('VISgrBubble', x[b], y[b], b / (n - 1.), $
                     size=_sizes[b mod nsizes], area=keyword_set(area), $
                     color=bubble_color, border_color=border_color, _extra=e)
  endfor
  
  return, arr
end


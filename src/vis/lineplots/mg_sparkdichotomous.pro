; docformat = 'rst'

;+
; Creates a dichotomous sparkline as a PNG image file.
; 
; :Todo:
;    maybe this should be a function that returns an image array instead of
;    directly creating the PNG; show example; add POSITION keyword and make it 
;    just do regular output in direct graphics as well (maybe using a FILENAME
;    keyword to create a file)
;-

;+
; Create a dichotomous sparkline as a PNG image file.
; 
; :Params:
;    filename : in, required, type=string
;       filename of PNG file to write
;    data : in, required, type=lonarr
;       values can be -1, 0, or +1
;
; :Keywords:
;    ysize : in, optional, type=integer, default=12
;       ysize in pixels of the output image
;    color : in, optional, type=bytarr(3) or index, default="[0, 0, 0] or 0"
;       color of the plot
;    background : in, optional, type=bytarr(3) or index, default="[255, 255, 255] or 255" 
;       background color for the plot
;-
pro mg_sparkdichotomous, filename, data, ysize=ysize, $
                         color=color, background=background
  compile_opt strictarr

  ndata = n_elements(data)
  multiplier = 1L

  _xsize = 2 * ndata - 1L
  _ysize = n_elements(ysize) eq 0 ? 12 : ysize 

  _color = n_elements(color) eq 0 ? bytarr(3) : color 
  _background = n_elements(background) eq 0 ? bytarr(3) + 255B : background

  band = bytarr(_xsize, _ysize)

  for i = 0L, ndata - 1L do begin
    case 1B of
      data[i] lt 0 : begin
          bar_min = 0
          bar_max = _ysize / 2 - 1L
        end
      data[i] gt 0 : begin
          bar_min = _ysize / 2
          bar_max = _ysize - 1L
        end
      else : begin
          bar_min = _ysize / 2 
          bar_max = _ysize / 2
        end
    endcase

    band[2 * i, bar_min:bar_max] = 1B
  endfor

  red = [_background[0], _color[0]]
  green = [_background[1], _color[1]]
  blue = [_background[2], _color[2]]

  alpha = [0B, 255B]
  hasAlpha = n_elements(background) eq 0

  image = bytarr(3 + hasAlpha, _xsize, _ysize)
  image[0, *, *] = red[band]
  image[1, *, *] = green[band]
  image[2, *, *] = blue[band]
  if (hasAlpha) then image[3, *, *] = alpha[band]

  write_png, filename, image
end

; docformat = 'rst'

;+
; Compute the gradient of an array.
;
; :Returns:
;   gradient array, 1- or 2-dimensional to match the dimensions of `arr`
;
; :Params:
;    arr : in, required, type=2D or 3D array
;       array to find gradient of
;    dx : in, optional, type=float, default=1.0
;       increment along `x`-axis
;    dy : in, optional, type=float, default=1.0
;       increment along `y`-axis
;-
function mg_gradient, arr, dx, dy
  compile_opt strictarr
  on_error, 2
  
  ndims = size(arr, /n_dimensions)
  dims = size(arr, /dimensions)

  ; set default x, y values, if needed
  switch ndims of
    2: _dy = n_elements(dy) eq 0L ? 1.0 : dy
    1: begin
        _dx = n_elements(dx) eq 0L ? 1.0 : dx
        break
      end
    else: message, 'invalid number of dimensions for input array'
  endswitch
  
  case ndims of
    1: return, deriv(findgen(dims[0]) * _dx, arr)
    2: begin        
        grad_x = (shift(arr, -1, 0) - shift(arr, 1, 0)) / (2. * _dx)
        grad_y = (shift(arr, 0, -1) - shift(arr, 0, 1)) / (2. * _dy)
        
        grad = make_array(dimension=[2, dims], type=size(arr, /type))

        grad[0, *, *] = grad_x
        grad[1, *, *] = grad_y
        
        return, grad
      end
    else:
  endcase
end


; main-level example program


d = dist(100L)

g = mg_gradient(d)

vis_decomposed, 0, old_decomposed=old_dec

window, xsize=600, ysize=600, /free

vis_loadct, 17, /brewer
vis_image, d, /axes, ticklen=-0.01

vis_loadct, 9, /brewer
vis_vel, g[0, *, *], g[1, *, *], /overplot, nvecs=500, thick=2

vis_decomposed, old_dec

end

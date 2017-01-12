; docformat = 'rst'

;+
; Concatenate two arrays over the given dimension. `x` and `y` must be of the
; same size except in the `DIMENSION` dimension. If one of `x` or `y` has one
; less dimension than the other, a new dimension of size 1 will be inserted in
; dimension `DIMENSION`. 
;
; :Returns:
;   array of type that can handle both `x` and `y`
;
; :Params:
;   x : in, required, type=array
;     first input array
;   y : in, required, type=array
;     second input array
;
; :Keywords:
;   dimension : in, required, type=integer, default=1
;     dimension 1, 2, or 3
;-
function mg_concatenate, x, y, dimension=dimension
  compile_opt strictarr

  _dimension = mg_default(dimension, 1L)

  x_ndims = size(x, /n_dimensions)
  x_dims  = size(x, /dimensions)
  y_ndims = size(y, /n_dimensions)
  y_dims  = size(y, /dimensions)

  if (x_ndims lt y_ndims) then begin
    _y_dims = y_dims

    _x_dims = lonarr(x_ndims + 1)
    _x_dims[0] = x_dims
    _x_dims[_dimension - 1] = 1
    if (_dimension lt x_ndims + 1) then _x_dims[_dimension] = x_dims[_dimension - 1:*]
  endif else if (x_ndims gt y_ndims) then begin
    _x_dims = x_dims

    _y_dims = lonarr(y_ndims + 1)
    _y_dims[0] = y_dims
    _y_dims[_dimension - 1] = 1
    if (_dimension lt y_ndims + 1) then _y_dims[_dimension] = y_dims[_dimension - 1:*]
  endif else begin
    _x_dims = x_dims
    _y_dims = y_dims
  endelse

  case _dimension of
    1: return, [reform(x, _x_dims), reform(y, _y_dims)]
    2: return, [[reform(x, _x_dims)], [reform(y, _y_dims)]]
    3: return, [[[reform(x, _x_dims)]], [[reform(y, _y_dims)]]]
  endcase
end

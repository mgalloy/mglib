; docformat = 'rst'

;+
; Create an `ncolumns` by `nrows` tiling of `arr`.
;
; :Returns:
;   2-dimensional array of the same type as `arr`
;
; :Params:
;   arr : in, required, type=numeric
;     scalar, 1-, or 2-dimensional numeric array
;   ncolumns : in, required, type=integer
;     number of horizontal tiles of `arr`
;   nrows : in, required, type=integer
;     number of vertical tiles of `arr`
;-
function mg_repmat, arr, ncolumns, nrows
  compile_opt strictarr
  on_error, 2

  if (n_params() lt 3L) then message, 'incorrect number of arguments'

  ndims = size(arr, /n_dimensions)
  if (ndims gt 2L) then message, 'input array must be at most 2-dimensional'

  _arr = ndims eq 0L ? [arr] : arr
  dims = lonarr(2) + 1L
  dims[0] = size(_arr, /dimensions)
  
  return, reform(transpose(rebin(reform(_arr, dims[0], dims[1], 1, 1), $
                                 dims[0], dims[1], ncolumns, nrows), $
                           [0, 2, 1, 3]), $
                 dims[0] * ncolumns, dims[1] * nrows)
end

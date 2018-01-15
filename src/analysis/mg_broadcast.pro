; docformat = 'rst'

;+
; Expand the dimensions of `x` to `dims` filling the new dimensions with copies
; of `x`.
;
; :Returns:
;   array of the size of `dims` with the values of `x`
;
; :Params:
;   x : in, required, type=numerical array
;     array of any numerical type and dimensions
;   dims : in, required, type=lonarr
;     dimensions of new array
;-
function mg_broadcast, x, dims
  compile_opt strictarr

  x_dims = size(x, /dimensions)
  empty_dims = dims * 0 + 1L
  x_d = 0
  for d = 0L, n_elements(dims) - 1L do begin
    if (dims[d] eq x_dims[x_d]) then begin
      empty_dims[d] = dims[d]
      x_d += 1
      if (x_d ge n_elements(x_dims)) then break
    endif
  endfor

  return, rebin(reform(x, empty_dims), dims)
end


; main-level example

x = findgen(5)
y = mg_broadcast(x, [3, 5, 2])

end

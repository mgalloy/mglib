; docformat = 'rst'

;+
; Returns the upper or lower triangular elements of a 2-dimensional array.
;
; :Returns:
;   2-dimensional array
;
; :Params:
;   a : in, required, type=2D array
;     matrix to grab upper or lower triangular elements of
;
; :Keywords:
;   upper : in, optional, type=boolean
;     set to return the upper triangular elements (one of `UPPER` or `LOWER`
;     must be set)
;   lower : in, optional, type=boolean
;     set to return the lower triangular elements (one of `UPPER` or `LOWER`
;     must be set)
;   strict : in, optional, type=boolean
;     set to not retrieve the diagonal elements (only the strictly upper/lower
;     trianguler elements)
;-
function mg_triangular, a, upper=upper, lower=lower, strict=strict
  compile_opt strictarr
  on_error, 2

  ndims = size(a, /n_dimensions)
  if (ndims ne 2L) then message, '2-dimensional array required'

  dims = size(a, /dimensions)
  if (dims[0] ne dims[1]) then message, 'square matrix required'

  n = dims[0]
  ii = indgen(n) # replicate(1, n)
  jj = replicate(1, n) # indgen(n)

  case 1 of
    keyword_set(upper): mask = keyword_set(strict) ? ii gt jj : ii ge jj
    keyword_set(lower): mask = keyword_set(strict) ? ii lt jj : ii le jj
    else: message, 'UPPER or LOWER keyword must be set'
  endcase

  return, a * mask
end
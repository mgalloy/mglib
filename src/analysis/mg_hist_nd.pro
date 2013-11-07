; docformat = 'rst'

;+
; Find the histogram of a set of `n`-dimensional points.
;
; :History:
;    16 January 2008, written by Michael Galloy.
;
;    Code adapted from `HIST_ND` from David Fanning and `HIST_ND_WEIGHT` by
;    Jeremy Bailin.
;
; :Examples:
;    Try::
;
;       IDL> q = transpose([[0.1 * findgen(40)], [0.2 * findgen(40)]])
;       IDL> print, mg_hist_nd(q, bin_size=1, weight=q, unweighted=unweighted)
;            0.500000      0.00000      0.00000      0.00000
;             2.50000      0.00000      0.00000      0.00000
;             0.00000      4.00000      0.00000      0.00000
;             0.00000      6.50000      0.00000      0.00000
;             0.00000      0.00000      7.50000      0.00000
;             0.00000      0.00000      10.5000      0.00000
;             0.00000      0.00000      0.00000      11.0000
;             0.00000      0.00000      0.00000      14.5000
;       IDL> print, unweighted
;                  5           0           0           0
;                  5           0           0           0
;                  0           5           0           0
;                  0           5           0           0
;                  0           0           5           0
;                  0           0           5           0
;                  0           0           0           5
;                  0           0           0           5
;       IDL> print, mg_hist_nd(q, nbins=[4, 8], max=[4.0, 8.0])
;                  5           0           0           0
;                  5           0           0           0
;                  0           5           0           0
;                  0           5           0           0
;                  0           0           5           0
;                  0           0           5           0
;                  0           0           0           5
;                  0           0           0           5
;
;    This example is in a main-level program at the end of this file. Run it
;    with::
;
;       IDL> .run mg_hist_nd
;
; :Returns:
;    histogram of size `n_1` by `n_2` by .... by `n_n`
;
; :Params:
;    array : in, required, type=numeric array
;       array to find histogram of; ndims by npoints array
;
; :Keywords:
;    bin_size : in, optional, type=numeric
;       the size of bin to use; either an n element vector or a scalar to use
;       for all dimensions; either `BIN_SIZE` or `NBINS` must be set
;    nbins : in, optional, type=long
;       the number of bins to use; either an n element vector or a scalar to
;       use for all dimensions; either `BIN_SIZE` or `NBINS` must be set
;    minimum : in, optional, type=float/fltarr(n), default="min(array, dim=2)"
;       set to either a scalar value to use for the minimum of each dimension
;       or a vector of values; if not specified, will use the natural minimum
;       in each dimension
;    maximum : in, optional, type=float/fltarr(n), default="max(array, dim=2)"
;       set to either a scalar value to use for the maximum of each dimension
;       or a vector of values; if not specified, will use the natural maximum
;       in each dimension
;    omin : out, optional, type=float/fltarr(n)
;       set to a named variable to return the minimum values used in computing
;       the histogram
;    omax : out, optional, type=float/fltarr(n)
;       set to a named variable to return the maximum values used in computing
;       the histogram
;    reverse_indices : out, optional, type=lonarr
;       set to a named variable to get 1-dimensional vector representing
;       the indices of the points that fall in a particular bin; to find the
;       indices of the points in bin [i, j, k], use the same formular as
;       when using `REVERSE_INDICES` with `HISTOGRAM` (after converting to
;       single dimensional indexing)::
;
;          ijk = [i + nx * j + nx * ny * k]
;          ind = ri[ri[ijk]:ri[ijk + 1] - 1]
;
;       See `ARRAY_INDICES` for converting `ind` back to 3-dimensional
;       indices.
;    weights : in, optional, type=numeric array
;       array with same dimensions as array containing a weight for each point
;    unweighted : out, optional, type=same as return value
;       set to a named variable to get the unweighted histogram
;    l64 : in, optional, type=boolean
;       set to return long64 results
;-
function mg_hist_nd, array, $
                     bin_size=binsize, nbins=nbins, $
                     minimum=minimum, maximum=maximum, $
                     omin=_minimum, omax=_maximum, $
                     reverse_indices=ri, $
                     weights=weights, unweighted=unweighted, $
                     l64=l64
  compile_opt strictarr

  dims = size(array, /dimensions)
  n = dims[0]

  if (n_elements(dims) ne 2L) then begin
    message, 'input must be 2-dimensional: dimensions by points'
  endif
  if (dims[0] gt 8L) then message, 'only up to 8 dimensions allowed'

  imx = max(array, dimension=2, min=imn)

  _maximum = n_elements(maximum) eq 0L ? imx : maximum
  _minimum = n_elements(minimum) eq 0L ? imn : minimum

  if (dims[0] gt 1L) then begin
    if (n_elements(_maximum) eq 1) then _maximum = replicate(_maximum, n)
    if (n_elements(_minimum) eq 1) then _minimum = replicate(_minimum, n)
    if (n_elements(binsize) eq 1) then binsize = replicate(binsize, n)
    if (n_elements(nbins) eq 1) then nbins = replicate(nbins, n)
  endif

  if (~array_equal(_minimum le _maximum, 1B)) then begin
    message, 'minimum must be less than or equal to maximum'
  endif

  if (n_elements(binsize) eq 0) then begin
    if (n_elements(nbins) ne 0) then begin
      nbins = long(nbins)
      binsize = float(_maximum - _minimum) / nbins
    endif else begin
      message, 'must pass either BIN_SIZE or NBINS'
    endelse
  endif else begin
    if (n_elements(nbins) eq 0) then begin
      nbins = long((_maximum - _minimum) / binsize + 1)
    endif else begin
      message, 'must pass either BIN_SIZE or NBINS'
    endelse
  endelse

  total_bins = product(nbins, /preserve_type)
  h = long((array[n - 1L, *] - _minimum[n - 1L]) / binsize[n - 1L])
  for i = dims[0] - 2L, 0L, -1L do begin
    h = nbins[i] * h + long((array[i, *] - _minimum[i]) / binsize[i])
  endfor

  out_of_range = [~array_equal(_minimum le imn, 1B), $
                  ~array_equal(_maximum ge imx, 1B)]
  if (~array_equal(out_of_range, 0B)) then begin
    in_range = 1B

    if (out_of_range[0]) then begin  ; too low
      minArray = rebin(_minimum, dims, /sample)
      in_range = total(array ge minArray, 1, /preserve_type) eq n
    endif

    if (out_of_range[1]) then begin  ; too high
      maxArray = rebin(_maximum, dims, /sample)
      in_range and= total(array le maxArray, 1, /preserve_type) eq n
    endif

    h = (temporary(h) + 1L) * in_range - 1L
  endif

  ; do the histogram, computing REVERSE_INDICES only if needed
  if (arg_present(ri) || n_elements(weights) gt 0L) then begin
    unweighted = histogram(h, min=0L, max=total_bins - 1L, $
                           reverse_indices=ri, l64=keyword_set(l64))
  endif else begin
    unweighted = histogram(h, min=0L, max=total_bins - 1L, $
                           l64=keyword_set(l64))
  endelse

  ; reform to correct dimensionality
  unweighted = reform(unweighted, nbins, /overwrite)

  ; handle weights, if present
  if (n_elements(weights) gt 0L) then begin
    weighted = make_array(dimension=size(unweighted, /dimensions), $
                          type=size(weights, /type))

    for i = 0L, n_elements(unweighted) - 1L do begin
      if (unweighted[i] gt 0) then begin
        q = ri[ri[i]:ri[i + 1L] - 1L]
        weighted[i] = total(weights[q])
      endif
    endfor

    return, weighted
  endif

  return, unweighted
end


; main-level example program

q = transpose([[0.1 * findgen(40)], [0.2 * findgen(40)]])
print, mg_hist_nd(q, bin_size=1, weights=q, unweighted=unweighted), unweighted
print, mg_hist_nd(q, nbins=[4, 8], max=[4.0, 8.0])

end

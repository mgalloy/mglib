; docformat = 'rst'

;+
; Finds the `n` smallest elements of a data array. This algorithm works 
; fastest on uniformly distributed data. The worst case for it is a single 
; smallest data element and all other elements with another value. This will 
; be nearly equivalent to just sorting all the elements and choosing the first 
; `n` elements.
;
; :Examples:
;    For example, to find the 3 smallest values of 10 random values, try::
;
;       IDL> r = randomu(seed, 10)
;       IDL> print, r, format='(4F)'
;             0.6297589      0.7815896      0.2508559      0.7546844
;             0.1353382      0.1245834      0.8733745      0.0753110
;             0.8054136      0.9513228
;       IDL> ind = mg_n_smallest(r, 3)
;       IDL> print, r[ind]
;             0.0753110     0.124583     0.135338
;
; :Returns:
;    index array
;
; :Params:
;    data : in, required, type=numeric array
;       data array of any numeric type (except complex/dcomplex)
;    n : in, required, type=integer
;       number of smallest elements to find
;
; :Keywords:
;    largest : in, optional, type=boolean
;       set to find `n` largest elements
;-
function mg_n_smallest, data, n, largest=largest
  compile_opt strictarr
  on_error, 2

  ; both parameters are required
  if (n_params() ne 2) then message, 'required parameters are missing'

  ; use histogram to find a set with more elements than n of smallest elements
  nData = n_elements(data)
  nBins = nData / n
  h = histogram(data, nbins=nBins, reverse_indices=ri)

  ; set parameters based on whether finding smallest or largest elements
  if (keyword_set(largest)) then begin
    startBin = nBins - 1L
    endBin = 0L
    inc = -1L
  endif else begin
    startBin = 0L
    endBin = nBins - 1L
    inc = 1L
  endelse

  ; loop through the bins until we have n or more elements
  nCandidates = 0L
  for bin = startBin, endBin, inc do begin
    nCandidates += h[bin]
    if (nCandidates ge n) then break
  endfor

  ; get the candidates and sort them
  candidates = keyword_set(largest) ? $
               ri[ri[bin] : ri[nBins] - 1L] : $
               ri[ri[0] : ri[bin + 1L] - 1L]
  sortedCandidates = sort(data[candidates])
  if (keyword_set(largest)) then sortedCandidates = reverse(sortedCandidates)

  ; return the proper n of them
  return, (candidates[sortedCandidates])[0:n-1L]
end

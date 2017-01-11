; docformat = 'rst'

;+
; Wrapper to `HISTOGRAM` function with added functionality which allows unequal
; sized bins and returns more easily handled information specifying which bin
; each elements was placed in.
;
; :Examples:
;   For example, let's bin data into unequal sized bins. First, we will create
;   some random data::
;
;     IDL> d = randomu(seed, 100)
;
;   The values in `d` will be distributed between 0.0 and 1.0, so let's
;   define our bins by their left-edges::
;
;     IDL> bins = [0.0, 0.25, 0.5, 0.6, 0.7, 0.8, 0.9]
;
;   This creates 7 bins, i.e., the last bin is from 0.9 to 1.0. Now we are ready
;   to histogram the data::
;
;     IDL> h = mg_histogram(d, bin_edges=bins, bin_indices=bi)
;
;   The `BIN_INDICES` returns the index of the bin for the corresponding data
;   value. The first 10 elements look like the following::
;
;      i      d[i] bi[i]
;     -- --------- ----
;      0  0.112424    0
;      1  0.074924    0
;      2  0.360270    1
;      3  0.716982    4
;      4  0.439055    1
;      5  0.463275    1
;      6  0.863777    5
;      7  0.776653    4
;      8  0.923320    6
;      9  0.248866    0
;
;   For example, `d[3]=0.716982` fell between `bins[4]` and `bins[5]`, so
;   `bi[3]=4`.
;
; :Returns:
;   `lonarr`
;
; :Params:
;   data : in, required, type=array
;     data to histogram
;
; :Keywords:
;   bin_edges : in, optional, type=array
;     array values to use to divide the range into bins, one for the left edge
;     of each bin
;   bin_indices : in, optional, type=lonarr
;     set to a named variable to retrieve bin index of each element in the array
;   locations : out, optional, type=array
;     set to named variable to retrieve the left edge of each bin; same as the
;     `HISTOGRAM` keyword of the same name
;   reverse_indices : out, optional, type=lonarr
;     set to a named variable to retrieve the list of reverse indices; same as
;     the `HISTOGRAM` keyword of the same name
;   _ref_extra : in, out, optional, type=keyword
;     keywords to `HISTOGRAM`
;-
function mg_histogram, data, $
                       bin_edges=bin_edges, $
                       locations=locations, $
                       bin_indices=bin_indices, $
                       reverse_indices=ri, $
                       _ref_extra=e
  compile_opt strictarr

  ; use bin_edges to create histogram with unequal bin sizes
  if (n_elements(bin_edges) gt 0L) then begin
    bins = value_locate(bin_edges, data, _extra=e)
    h = histogram(bins, reverse_indices=ri, _extra=e)
    if (arg_present(locations)) then locations = bin_edges
  endif else h = histogram(data, locations=locations, reverse_indices=ri, _extra=e)

  if (arg_present(bin_indices)) then begin
    bin_indices = lonarr(n_elements(data))
    for b = 0L, ri[0] - 2L do begin
      if (ri[b] ne ri[b + 1]) then bin_indices[ri[ri[b]:ri[b + 1] - 1]] = b
    endfor
  endif

  return, h
end


; main-level example program

n = 10
d = randomu(seed, n)

; create unequal bin sizes
bins = [0.0, 0.25, 0.5, 0.6, 0.7, 0.8, 0.9]
h = mg_histogram(d, bin_edges=bins, bin_indices=bi)
print, strjoin(string(bins, format='(%"%0.2f")'), ', '), format='(%"bin left edge: %s")'
print, ' i      d[i] bi[i]'
print, '-- --------- ----'
for i = 0L, n - 1L do print, i, d[i], bi[i], format='(%"%2d  %f %4d")'

print

; return the bin index for each element
nbins = 10
h = mg_histogram(d, nbins=nbins, min=0.0, binsize=0.1, bin_indices=bi, locations=bins)
print, strjoin(string(bins, format='(%"%0.1f")'), ', '), format='(%"bin left edge: %s")'
print, ' i      d[i] bi[i]'
print, '-- --------- ----'
for i = 0L, n - 1L do print, i, d[i], bi[i], format='(%"%2d  %f %4d")'

end

; docformat = 'rst'

;+
; Calculate sum of the elements in each of the bins of a histogram.
;
; :Returns:
;   array the same dimensionality has `h` and the same type as `data`
;
; :Params:
;   data : in, required, type=numeric array
;     data that has been histogramed
;   h : in, required, type=integer array
;     histogram of data
;   ri : in, required, type=integer array
;     `REVERSE_INDICES` output for `HISTOGRAM`
;-
function mg_sum_reverse_indices, data, h, ri
  compile_opt strictarr

  sum = h * fix(0, type=size(data, /type))

  nonzero_bins = where(h gt 0L, n_nonzero_bins)
  if (n_nonzero_bins gt 0L) then begin
    for b = 0L, n_nonzero_bins - 1L do begin
      if (ri[nonzero_bins[b] + 1] gt ri[nonzero_bins[b]]) then begin
        ind = ri[ri[nonzero_bins[b]]:ri[nonzero_bins[b] + 1L] - 1L]
        sum[nonzero_bins[b]] = total(data[ind], /preserve_type)
      endif
    endfor
  endif

  return, sum
end


; main-level example program

a = randomu(seed, 10000, /double)
h = histogram(a, min=0.0D, max=0.9D, nbins=10, reverse_indices=ri)

b = mg_sum_reverse_indices(a, h, ri)
squares = mg_sum_reverse_indices(a ^ 2, h, ri)

m = b / h
sdev = sqrt(squares / (h - 1) - 2.0D * m * b / (h - 1L) + m^2 * h / (h - 1L))

; check mean and stddev for elements in bin 5:
i = 5
el = a[ri[ri[i]:ri[i + 1] - 1]]
print, mean(el, /double), stddev(el, /double)
print, m[i], sdev[i]

end

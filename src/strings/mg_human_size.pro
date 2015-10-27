;+
; Return a human readable array of sizes using bytes, kilobytes, megabytes,
; gigabytes, terabytes, and petabytes (in powers of two).
;
; :Private:
;
; :Returns:
;    `strarr`
;
; :Params:
;    sizes : in, required, type=intarr
;       array of sizes in bytes
;-
function mg_human_size, sizes
  compile_opt strictarr, hidden

  nSizes = n_elements(sizes)
  results = strarr(nSizes)
  units = ['B', 'K', 'M', 'G', 'T', 'P']
  for i = 0L, nSizes - 1L do begin
    level = 0L
    s = sizes[i]
    while (s ge 1024L) do begin
      s /= 1024L
      level++
    endwhile
    results[i] = strtrim(s, 2) + units[level]
  endfor

  return, results
end
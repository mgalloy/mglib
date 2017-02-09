;+
; Return a human readable array of sizes using bytes, kilobytes, megabytes,
; gigabytes, terabytes, and petabytes.
;
; :Private:
;
; :Examples:
;   For example, try::
;
;     IDL> print, mg_human_size([2387203222ULL, 12121, 13872960])
;     2G 12K 13M
;     IDL> print, mg_human_size([2387203222ULL, 12121, 13872960], /si)
;     2G 12K 14M
;     IDL> print, mg_human_size([2387203222ULL, 12121, 13872960], decimal_places=2)
;     2.22G 11.84K 13.23M
;     IDL> print, mg_human_size([2387203222ULL, 12121, 13872960], /long)
;     2GB 12KB 13MB
;     IDL> print, mg_human_size([2387203222ULL, 12121, 13872960], /bits)
;     2Gb 12Kb 13Mb
;
; :Returns:
;    string or `strarr`
;
; :Params:
;    sizes : in, required, type=intarr
;       array of sizes in bytes
;
; :Keywords:
;   si : in, optional, type=boolean
;     set to use powers of 1000 instead of 1024
;   decimal_places : in, optional, type=integer, default=0
;     set a number of decimal places to report the result to
;   long : in, optional, type=boolean
;     set to use long names, i.e, 'GB' instead of 'G'
;   bits : in, optional, type=boolean
;     set to output numbers of bits, i.e., 'Gb' instead of 'GB'
;-
function mg_human_size, sizes, $
                        si=si, $
                        decimal_places=decimal_places, $
                        long=long, $
                        bits=bits
  compile_opt strictarr

  if (n_elements(decimal_places) eq 0L || decimal_places eq 0) then begin
    round_to = 1
    format = '(%"%d%s")'
  endif else begin
    round_to = 10.0^(-decimal_places)
    format = string(decimal_places, format='(%"(%%\"%%0.%df%%s\")")')
  endelse

  n_sizes = n_elements(sizes)
  results = strarr(n_sizes)

  units = ['B', 'K', 'M', 'G', 'T', 'P', 'E']
  n_units = n_elements(units)
  if (keyword_set(long) || keyword_set(bits)) then begin
    units += ['', $
              strarr(n_units - 1L) $
                + (keyword_set(si) ? '' : 'i') $
                + (keyword_set(bits) ? 'b' : 'B')]
  endif

  powers_of = keyword_set(si) ? 1000.0 : 1024.0

  for i = 0L, n_sizes - 1L do begin
    level = 0L
    s = sizes[i]
    while (s ge powers_of && level lt (n_units - 1L)) do begin
      s /= powers_of
      level++
    endwhile

    results[i] = string(mg_round(s, round_to), units[level], format=format)
  endfor

  return, size(sizes, /n_dimensions) eq 0L ? results[0] : results
end
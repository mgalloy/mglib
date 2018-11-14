; docformat = 'rst'

;+
; Repeat a given string `s` a specific number of times `n`.
;
; :Returns:
;   string/strarr
;
; :Params:
;   s : in, required, type=string
;     string to repeat
;   n : in, required, type=long/lonarr
;     number of times to repeat `s`; if an array, then returns an array
;-
function mg_repstr, s, n
  compile_opt strictarr

  is_scalar = size(n, /n_dimensions) eq 0
  if (is_scalar) then begin
    result = strjoin(strarr(n) + s)
  endif else begin
    result = strarr(n_elements(n))
    for r = 0L, n_elements(n) - 1L do result[r] = mg_repstr(s, n[r])
  endelse

  return, result
end

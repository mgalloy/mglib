; docformat = 'rst'

;+
; Find combinations of choosing `k` symbols from `n` symbols.
;
; :Private:
;
; :Returns:
;   `list` of `lonarr(k)`
;-
function mg_find_combinations_, n, k, b
  compile_opt strictarr

  _b = mg_default(b, 0L)
  if (k le 0L) then begin
    return, list([])
  endif else begin
    combinations = list()
    for i = _b, n - 1L do begin
      combos = mg_find_combinations_(n, k - 1, i + 1)
      foreach c, combos do begin
        combinations->add, [i, c]
      endforeach
      obj_destroy, combos
    endfor
    return, combinations
  endelse
end


;+
; Find combinations of choosing `k` symbols from `n` symbols with replacement.
;
; :Private:
;
; :Returns:
;   `list` of `lonarr(k)`
;-
function mg_find_combinations_w_r_, n, k, b
  compile_opt strictarr

  _b = mg_default(b, 0L)
  if (k le 0L) then begin
    return, list([])
  endif else begin
    combinations = list()
    for i = _b, n - 1L do begin
      combos = mg_find_combinations_w_r_(n, k - 1, i)
      foreach c, combos do begin
        combinations->add, [i, c]
      endforeach
      obj_destroy, combos
    endfor
    return, combinations
  endelse
end


;+
; Find combinations of choosing `k` symbols from `n` symbols, with or without
; replacement.
;
; :Private:
;
; :Returns:
;   `lonarr(k, n_combinations)`
;
; :Params:
;   n : in, required, type=integer
;     number of symbols to choose from
;   k : in, required, type=integer
;     number of symbols to choose
;
; :Keywords:
;   with_replacement : in, optional, type=boolean
;     set to choose with replacement
;   count : out, optional, type=long
;     set to a named variable to retrieve the number of combinations returned
;-
function mg_find_combinations, n, k, $
                               with_replacement=with_replacement, $
                               count=count
  compile_opt strictarr

  if (keyword_set(with_replacement)) then begin
    result = mg_find_combinations_w_r_(n, k)
  endif else begin
    result = mg_find_combinations_(n, k)
  endelse

  count = result->count()
  array = result->toArray(/transpose)
  obj_destroy, result
  return, array
end


; main-level example program

n = 8
k = 3

combos = mg_find_combinations(n, k, /with_replacement, count=n_combinations)
print, combos
help, combos
print, n, k, k, mg_choose(n + k - 1, k), format='(%"mg_choose(%d + %d - 1, %d) = %d")'
print, n_combinations, format='(%"n_combinations = %d")'

print

combos = mg_find_combinations(n, k, count=n_combinations)
print, combos
help, combos
print, n, k, mg_choose(n, k), format='(%"mg_choose(%d, %d) = %d")'
print, n_combinations, format='(%"n_combinations = %d")'

end

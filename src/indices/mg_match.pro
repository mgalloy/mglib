; docformat = 'rst'

;+
;	Routine to match values between two arrays.
;
; :Returns:
;   long, number of matches found
;
; :Params:
;   a, b : in, required, type=array
;     arrays to match
;
; :Keywords:
;   a_matches : out, optional, type=`lonarr`
;     set to a named variable to retrieve the indices of `a` which match
;     elements of `b` or `!null` if no matches found
;   b_matches : out, optional, type=`lonarr`
;     set to a named variable to retrieve the indices of `b` which match
;     elements of `a` or `!null` if no matches found; the `a_matches` and
;     `b_matches` are given in the same order, so for any
;     `i = 0...n_matches - 1` then::
;
;       a[a_matches[i]] eq b[b_matches[i]]
;-
function mg_match, a, b, a_matches=a_matches, b_matches=b_matches
  compile_opt strictarr

  na = n_elements(a)
  nb = N_elements(b)

  both = [a, b]
  ind = [lindgen(na), lindgen(nb)]
  flag = [bytarr(na), bytarr(nb) + 1B]

  sub = sort(both)

  both = both[sub]
  ind = ind[sub]
  flag = flag[sub]

  ; find matches
  matches = where((both eq shift(both, -1)) and (flag ne shift(flag, -1)), $
                  n_matches)

  if (n_matches eq 0L) then begin
    a_matches = !null
    b_matches = !null
    return, 0L
  endif

  matches = transpose([[matches], [matches + 1L]])

  ind = ind[matches]     ; indices of matches
  flag = flag[matches]   ; which array for matches

  a_where = where(flag eq 0L)
  a_matches = ind[a_where]   ; a subscripts
  b_where = where(flag eq 1L)
  b_matches = ind[b_where]   ; b subscripts

  return, n_matches
end


; main-level example program

a = [0, 1, 3, 4, 5]
b = [3, 5, 6, 7, 0, 2]

n_matches = mg_match(a, b, a_matches=a_matches, b_matches=b_matches)

print, strjoin(strtrim(a_matches, 2), ', '), format='(%"a matches: %s")'
print, strjoin(strtrim(b_matches, 2), ', '), format='(%"b matches: %s")'

for m = 0L, n_matches - 1L do begin
  print, a_matches[m], a[a_matches[m]], b_matches[m], b[b_matches[m]], $
         format='(%"a[%d] = %d, b[%d] = %d")'
endfor

end
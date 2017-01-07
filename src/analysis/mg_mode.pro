; docformat = 'rst'

;+
; Find the most common value in an array of integers.
;
; :Returns:
;   scalar of the same type as `x`
;
; :Params:
;   x : in, required, type=integer array
;     array to find mode of
;
; :Keywords:
;   n_occurences : out, optional, type=integer
;     number of times the mode appears in the array
;-
function mg_mode, x, n_occurences=n_occurences
  compile_opt strictarr
  on_error, 2

  max_histogram_size = 100000L
  x_min = min(x, max=x_max)

  if (x_max - x_min lt max_histogram_size) then begin
    ; this might use a lot of memory
    n_occurences = max(histogram(x), max_position)
    mode = x_min + max_position
  endif else begin
    ; this is slower in general, but won't create a huge histogram
    _x = x[sort(x)] 
    ind = where(_x ne shift(_x, -1), n_occurences)
    if (n_occurences eq 0L) then mode = array[0] else begin
      !null = max(ind - [-1, ind], max_position)
      mode = _x[ind[max_position]]
    endelse 
  endelse

  return, mode
end


; main-level example program

x = [1, 3, -1, 7, 3, 4, 5, -2, 3, 8]
print, strjoin(strtrim(x, 2), ', '), format='(%"\n# Find mode of integer array: %s")'
print, mg_mode(x), format='(%"mode: %d")'

x = [1, 3, -1, 7, 3, 4, 5, -2, 3, 8, 10000000]
print, strjoin(strtrim(x, 2), ', '), $
       format='(%"\n# Find mode of integer array with a high value: %s")'
print, mg_mode(x), format='(%"mode: %d")'

n = 1000
round_to = 0.01
print, n, round_to, $
       format='(%"\n# Find mode of randomu(seed, %d) rounded to nearest %0.2f")'
x = randomu(seed, n)
x_new = round(x / round_to)
mode = mg_mode(x_new, n_occurences=n_occurences)
print, mode * round_to, n_occurences, $
       format='(%"mode: %0.2f (%d times)")'

end

; docformat = 'rst'

;+
; Generate indices to permute the elements of an array.
;
; :Examples:
;   Try the main-level example program at the end of this file::
;
;     IDL> .run mg_shuffle
;
; :Returns:
;   `lonarr`
;
; :Params:
;   x : in, required, type=array
;     array to shuffle or scalar integer of number of values to shuffle
;
; :Keywords:
;   dimension : in, optional, type=integer
;     optionally, only shuffle a particular dimension of the array
;   seed : in, out, optional, type=long/lonarr
;     seed to `RANDOMU`
;-
function mg_shuffle, x, dimension=dimension, seed=seed
  compile_opt strictarr
  on_error, 2

  n_dims = size(x, /n_dimensions)
  dims = size(x, /dimensions)

  if (n_dims eq 0L) then begin
    n = x
  endif else if (n_elements(dimension) gt 0L) then begin
    n = dims[dimension - 1]
  endif else begin
    n = n_elements(x)
  endelse

  random_values = randomu(seed, n)
  ind = sort(random_values)
  return, n_dims gt 0L && n_elements(dimension) eq 0L ? reform(ind, dims) : ind
end


; main-level example program

print, 'Generate a permutation of the 0:7...'
print, mg_shuffle(8)

print, 'A 2-dimensional example'
x = findgen(3, 5)
print, x

print, 'Shuffle all the elements...'
ind = mg_shuffle(x)
print, x[ind]

print, 'Shuffle the columns...'
ind = mg_shuffle(x, dimension=1)
print, x[ind, *]

print, 'Shuffle the rows...'
ind = mg_shuffle(x, dimension=2)
print, x[*, ind]

end

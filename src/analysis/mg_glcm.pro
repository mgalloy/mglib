; docformat = 'rst'


;+
; Computes the grey-level co-occurence matrix as defined
; `here <http://en.wikipedia.org/wiki/Co-occurrence_matrix>`.
;
; :Returns:
;   2-dimensional matrix
;
; :Params:
;   m : in, required, type=integer array
;     input matrix
;   x : in, optional, type=integer, default=1
;     shift in columns
;   y : in, optional, type=integer, default=0
;     shift in rows
;
; :Keywords:
;   symmetric : in, optional, type=boolean
;     set to indicate that the ordering of the reference pixel and offset pixel
;     does not matter
;   n_levels : in, required, type=integer
;     number of grey levels to use; default is the difference between maximum
;     and minimum plus 1
;-
function mg_glcm, m, x, y, symmetric=symmetric, n_levels=n_levels
  compile_opt strictarr

  dims = size(m, /dimensions)

  range = mg_range(m)
  r = range[1] - range[0]
  _x = n_elements(x) eq 0L ? 1L : x
  _y = n_elements(x) eq 0L ? 0L : y
  _n_levels = n_elements(n_levels) eq 0L ? (r + 1L) : n_levels
  result = lonarr(_n_levels, _n_levels)

  for row = 0L, dims[1] - 1L do begin
    if (row + y lt dims[1]) then begin
      for col = 0L, dims[0] - 1L do begin
        if (col + x lt dims[0]) then begin
          i = m[col, row]
          j = m[col + _x, row + _y]

          i_index = floor((i - range[0]) * (_n_levels - 0.5) / r)
          j_index = floor((j - range[0]) * (_n_levels - 0.5) / r)

          result[j_index, i_index]++
          if (keyword_set(symmetric)) then result[i_index, j_index]++
        endif
      endfor
    endif
  endfor

  return, result
end


; main-level example program

im = [[0B, 0B, 1B, 1B], $
      [0B, 0B, 1B, 1B], $
      [0B, 2B, 2B, 2B], $
      [2B, 2B, 3B, 3B]]

glcm = mg_glcm(im, 1, 0, /symmetric)

; compute contrast as defined by http://www.fp.ucalgary.ca/mhallbey/tutorial.htm
p = glcm / total(glcm)
n = (size(glcm, /dimensions))[0]
weights = (lindgen(n) # (lonarr(n) + 1L) - (lonarr(4) + 1L) # lindgen(4))^2
contrast = total(p * weights, /preserve_type)

end

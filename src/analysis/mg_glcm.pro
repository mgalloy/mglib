; docformat = 'rst'

;+
; Determines the number of values of a given type.
;
; :Private:
;
; :Returns:
;   long, unsigned long 64
;
; :Params:
;   type_code : in, required, type=long
;     `SIZE` type code of data
;-
function mg_glcm_size, type_code
  compile_opt strictarr
  on_error, 2

  case type_code of
    1: return, 2L^8
    2: return, 2L^16
    3: return, 2ULL^32
    12: return, 2L^16
    13: return, 2ULL^32
    14: return, 2ULL^64
    15: return, 2ULL^64
    else: message, 'unable to compute for given type'
  endcase
end


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
;   x : in, required, type=integer
;     shift in columns
;   y : in, required, type=integer
;     shift in rows
;-
function mg_glcm, m, x, y
  compile_opt strictarr

  dims = size(m, /dimensions)
  result_dim = mg_glcm_size(size(m, /type))
  result = lonarr(result_dim, result_dim)

  for row = 0L, dims[1] - 1L do begin
    if (row + y lt dims[1]) then begin
      for col = 0L, dims[0] - 1L do begin
        if (col + x lt dims[0]) then begin
          i = m[col, row]
          j = m[col + x, row + y]
          result[j, i]++
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

glcm = mg_glcm(im, 1, 0)

end

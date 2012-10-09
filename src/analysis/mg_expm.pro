; docformat = 'rst'

;+
; Exponential of a matrix.
;
; :Returns:
;   2-dimensional array of the same size as `m`
;
; :Params:
;   m : in, required, type=2-dimensional array
;     matrix to find exponential of
;-
function mg_expm, m
  compile_opt strictarr

  eigenvals = la_eigenproblem(m, eigenvectors=evecs)
  expm = evecs # diag_matrix(exp(eigenvals)) # invert(evecs)

  return, expm
end

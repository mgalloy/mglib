; docformat = 'rst'

;+
; Natural logarithm of a matrix.
;
; :Returns:
;   2-dimensional array of the same size as `m`
;
; :Params:
;   m : in, required, type=2-dimensional array
;     matrix to find natural logarithm of
;-
function alogm, m
  compile_opt strictarr

  eigenvals = la_eigenproblem(m, eigenvectors=evecs)
  logm = evecs # diag_matrix(alog(eigenvals)) # invert(evecs)

  return, logm
end

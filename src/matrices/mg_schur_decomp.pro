; docformat = 'rst'

;+
; Compute the Schur decomposition of `A`. Returns upper triangular Schur form,
; `U` below. Retrieve unitary matrix `Q` via the output keyword.
;
; If `A` is a `n` × `n` square matrix with complex entries, then `A` can be
; expressed as:
;
;   $$A = Q U Q^{-1}$$
;
; where Q is a unitary matrix (so that its inverse $Q^{−1}$ is also the
; conjugate transpose Q* of Q), and U is an upper triangular matrix.
;
; :Returns:
;   `fltarr` of same size as `A`, `dblarr` if `DOUBLE` is set
;
; :Params:
;   a : in, required, type=2-dimensional numeric array
;     input matrix
;
; :Keywords:
;   q : out, optional, type=array of same size as A
;     unitary matrix Q
;   double : in, optional, type=boolean
;     set to perform computations in double precision
;-
function mg_schur_decomp, A, Q=Q, double=double
  compile_opt strictarr

  U = la_elmhes(A, Q, double=double)
  !null = la_hqr(U, Q, double=double)
  return, U
end


; main-level example program

n = 5
a = randomu(seed, n, n)
if (keyword_set(do_complex)) then a +=complex(0.0, 1.0) * randomu(seed, n, n)
u = mg_schur_decomp(a, q=q)

print, a
print
print, q ## u ## mg_hermitian(q)

end

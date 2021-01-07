; docformat = 'rst'

;+
; Compute the Schur decomposition of `a`.
;
; If `A` is a `n` × `n` square matrix with complex entries, then `A` can be
; expressed as:
;
;   $$A = Q U Q^{-1}$$
;
; where Q is a unitary matrix (so that its inverse $Q^{−1}$ is also the
; conjugate transpose Q* of Q), and U is an upper triangular matrix.
;-
function mg_schur_decomp, a, q=q, double=double
  compile_opt strictarr

  u = la_elmhes(a, q, double=double)
  !null = la_hqr(u, q, double=double)
  return, u
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

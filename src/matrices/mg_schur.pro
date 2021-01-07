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
function mg_schur, a, q=q, double=double
  compile_opt strictarr

  u = la_elmhes(a, q, double=double)
  !null = la_hqr(u, q, double=double)
  return, u
end


; main-level example program

n = 5
a = randomu(seed, n, n)
u = mg_schur(a, q=q)

print, a
print
print, float(q ## u ## conj(transpose(q)))

end

; docformat = 'rst'

function mg_matrix_sqrt, x
  compile_opt strictarr

  h = la_elmhes(x, q)
  t = la_hqr(h, q)
end


; main-level example program

n = 5
x = randomu(seed, n, n)
s = mg_matrix_sqrt(x)
t = matrix_multiply(s, s)
print, x - t

end

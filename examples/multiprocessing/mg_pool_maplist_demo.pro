; docformat = 'rst'

function mg_pool_maplist_demo, im1, im2
  compile_opt strictarr

  return, im1 + im2
end


; main-level example program

pool = mg_pool()

n_ims = 5L
n = 10L
im1s = list()
im2s = list()
for i = 0L, n_ims - 1L do begin
  im1s->add, randomu(seed, n, n)
  im2s->add, randomu(seed, n, n)
endfor

sums = pool->map('mg_pool_maplist_demo', im1s, im2s)
help, sums

end

; docformat = 'rst'

function mg_map_demo_func, x
  compile_opt strictarr

  r = randomu(seed, 1)
  wait, 10. * r[0]
  return, x^2
end


pro mg_map_demo
  compile_opt strictarr

  pool = obj_new('MG_Pool')

  n = 100L
  x = findgen(n)
  x_squared = pool->map('mg_map_demo_func', x)

  help, x_squared
  print, x_squared

  obj_destroy, pool
end

; docformat = 'rst'


;+
; Demo of using `MG_Pool::map` method to map a function over an array of
; values.
;-
pro mg_map_demo
  compile_opt strictarr

  pool = obj_new('MG_Pool')

  n = 100L
  x = findgen(n)
  x_squared = pool->map('mg_map_demo_func', x)

  help, x_squared
  print, x_squared, format='(10(F8.1))'

  obj_destroy, pool
end

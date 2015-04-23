; docformat = 'rst'

;+
; Demo of using `MG_Pool::map` method to map a function over an array of
; values.
;
; :Examples:
;   To run this demo::
;
;     IDL> .run mg_map_demo
;     IDL> .run mg_map_demo
;     X_SQUARED       FLOAT     = Array[100]
;          0.0     1.0     4.0     9.0    16.0    25.0    36.0    49.0
;         64.0    81.0   100.0   121.0   144.0   169.0   196.0   225.0
;        256.0   289.0   324.0   361.0   400.0   441.0   484.0   529.0
;        576.0   625.0   676.0   729.0   784.0   841.0   900.0   961.0
;       1024.0  1089.0  1156.0  1225.0  1296.0  1369.0  1444.0  1521.0
;       1600.0  1681.0  1764.0  1849.0  1936.0  2025.0  2116.0  2209.0
;       2304.0  2401.0  2500.0  2601.0  2704.0  2809.0  2916.0  3025.0
;       3136.0  3249.0  3364.0  3481.0  3600.0  3721.0  3844.0  3969.0
;       4096.0  4225.0  4356.0  4489.0  4624.0  4761.0  4900.0  5041.0
;       5184.0  5329.0  5476.0  5625.0  5776.0  5929.0  6084.0  6241.0
;       6400.0  6561.0  6724.0  6889.0  7056.0  7225.0  7396.0  7569.0
;       7744.0  7921.0  8100.0  8281.0  8464.0  8649.0  8836.0  9025.0
;       9216.0  9409.0  9604.0  9801.0
;-


;+
; Example function to be mapped over an array of values.
;
; Waits a random amount of time, 0.0 to 5.0 seconds, before it squares its
; input value.
;
; :Returns:
;   numeric same as `x`
;
; :Params:
;   x : in, required, type=numeric
;     input value to be squared
;-
function mg_map_demo, x
  compile_opt strictarr

  r = randomu(seed, 1)
  wait, 5. * r[0]

  return, x^2
end


; main-level example program

pool = obj_new('MG_Pool')

n = 100L
x = findgen(n)
x_squared = pool->map('mg_map_demo', x)

help, x_squared
print, x_squared, format='(10(F8.1))'

obj_destroy, pool

end

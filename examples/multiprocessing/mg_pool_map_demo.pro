; docformat = 'rst'

;+
; Demo of using `MG_Pool::map` method to map a function over an array of
; values.
;
; :Examples:
;   To run this demo::
;
;     IDL> .run mg_map_demo
;     X_SQUARED       FLOAT     = Array[100]
;           0.00      1.12      5.00     12.38     24.00     40.62     63.00     91.88
;         128.00    172.12    225.00    287.38    360.00    443.62    539.00    646.88
;         768.00    903.12   1053.00   1218.38   1400.00   1598.62   1815.00   2049.88
;        2304.00   2578.12   2873.00   3189.38   3528.00   3889.62   4275.00   4684.88
;        5120.00   5581.12   6069.00   6584.38   7128.00   7700.62   8303.00   8935.88
;        9600.00  10296.12  11025.00  11787.38  12584.00  13415.62  14283.00  15186.88
;       16128.00  17107.12  18125.00  19182.38  20280.00  21418.62  22599.00  23821.88
;       25088.00  26398.12  27753.00  29153.38  30600.00  32093.62  33635.00  35224.88
;       36864.00  38553.12  40293.00  42084.38  43928.00  45824.62  47775.00  49779.88
;       51840.00  53956.12  56129.00  58359.38  60648.00  62995.62  65403.00  67870.88
;       70400.00  72991.12  75645.00  78362.38  81144.00  83990.62  86903.00  89881.88
;       92928.00  96042.12  99225.00 102477.38 105800.00 109193.62 112659.00 116196.88
;      119808.00 123493.12 127253.00 131088.38
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
;     first input value
;   y : in, required, type=numeric
;     second input value
;-
function mg_pool_map_demo, x, y, multiplier=multiplier
  compile_opt strictarr

  _multiplier = n_elements(multiplier) eq 0L ? 5. : multiplier
  r = randomu(seed, 1)
  wait, _multiplier * r[0]

  return, x^2 + y^3
end


; main-level example program

t0 = systime(/seconds)
pool = obj_new('MG_Pool')
t1 = systime(/seconds)

pool->getProperty, n_processes=n_processes
mg_log, '%0.1f sec to create pool with %d processs', t1 - t0, n_processes

n = 100L
multiplier = 2.5
x = findgen(n)
y = 0.5 * findgen(n)
t0 = systime(/seconds)
x_squared = pool->map('mg_pool_map_demo', x, y, multiplier=multiplier)
t1 = systime(/seconds)

expected = multiplier * 0.5 * ceil(float(n) / n_processes)
mg_log, '%0.1f sec to find result (approx %0.1f sec of work)', $
        t1 - t0, expected

mg_log, '%0.1f%% overhead', (t1 - t0 - expected) / (t1 - t0) * 100.

help, x_squared
print, x_squared, format='(8(F10.2))'

obj_destroy, pool

end

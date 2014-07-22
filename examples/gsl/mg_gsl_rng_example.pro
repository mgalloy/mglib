; docformat = 'rst'

;+
; Example of using GSL bindings to produce random numbers.
;
; :Keywords:
;   n : in, optional, type=integer, default=1000
;     number of random numbers to generate
;-
pro mg_gsl_rng_example, n=n
  compile_opt strictarr

  _n = n_elements(n) eq 0L ? 1000L : n

  mg_gsl_rng_env_setup
  t = mg_gsl_rng_default()
  r = mg_gsl_rng_alloc(t)

  u = dblarr(_n)
  for i = 0L, _n - 1L do begin
    u[i] = mg_gsl_rng_uniform(r)
  endfor

  print, _n, mean(u), stddev(u), $
         format='(%"%d doubles generated; mean = %f, stddev = %f")'
end

; docformat = 'rst'

;+
; Comparison of GSL RNG generated random numbers to IDL's.
;
; :Keywords:
;   n : in, optional, type=integer, default=1000
;     number of random numbers to generate
;   seed : in, optional, type=unsigned long64, default=12345ULL
;     seed to use for random number generators
;-
pro mg_gsl_rng_comparison, n=n, seed=seed
  compile_opt strictarr

  _n = n_elements(n) eq 0L ? 1000L : n
  original_seed = n_elements(seed) eq 0L ? 123456ULL : seed
  _seed = original_seed

  mg_gsl_rng_env_setup
  t = mg_gsl_rng_mt19937()
  r = mg_gsl_rng_alloc(t)
  mg_gsl_rng_set, r, _seed

  gsl_r = dblarr(_n)
  for i = 0L, _n - 1L do gsl_r[i] = mg_gsl_rng_uniform(r)

  _seed = original_seed
  idl_r = double(randomu(_seed, _n))

  print, _n, format='(%"%d random numbers generated")'

  err = total(abs(idl_r - gsl_r), /preserve_type)
  print, err, format='(%"Total difference between IDL and GSL: %f")'
end
